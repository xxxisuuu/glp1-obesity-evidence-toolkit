# =============================================================================
# shiny/app.R
#
# Interactive companion to analysis/01_sample_size_scenarios.R and
# analysis/02_nma_analysis.R.
#
# Run from the repository root with:
#   shiny::runApp("shiny")
# =============================================================================

suppressPackageStartupMessages({
  library(shiny)
  library(ggplot2)
  library(DT)
})

source("../R/sample_size.R")
source("../R/nma_helpers.R")

armdata <- read_armdata("../data/glp1_trials_armlevel.csv")
all_treatments <- sort(unique(armdata$treat_label))

ui <- fluidPage(
  titlePanel("GLP-1 Obesity Evidence Toolkit"),
  h5(em("Market positioning determines trial design — an interactive companion to the project design document")),
  tabsetPanel(

    tabPanel("Sample size calculator",
      sidebarLayout(
        sidebarPanel(
          h4("Efficacy assumptions"),
          sliderInput("delta", "Assumed placebo-adjusted effect (percentage points)",
                      min = 2, max = 20, value = 8, step = 0.5),
          sliderInput("sd", "Assumed SD of the primary endpoint (pp)",
                      min = 5, max = 15, value = 10, step = 0.5),
          sliderInput("power", "Target power", min = 0.7, max = 0.99, value = 0.9, step = 0.01),
          sliderInput("alpha", "Two-sided alpha", min = 0.01, max = 0.10, value = 0.05, step = 0.01),
          sliderInput("ratio", "Allocation ratio (active : control)", min = 1, max = 3, value = 2, step = 0.5),
          sliderInput("dropout", "Expected dropout", min = 0, max = 0.4, value = 0.2, step = 0.05),
          h4("FDA 2025 draft guidance safety floor"),
          numericInput("min_active", "Minimum active-arm exposure (1 year)", value = 3000, step = 100),
          numericInput("min_control", "Minimum control-arm exposure (1 year)", value = 1500, step = 100),
          helpText("Source: FDA draft guidance, \"Obesity and Overweight: Developing Drugs",
                   "and Biological Products for Weight Reduction\" (Jan 2025).")
        ),
        mainPanel(
          h4("Result"),
          tableOutput("ss_table"),
          textOutput("ss_message"),
          plotOutput("ss_plot", height = "380px")
        )
      )
    ),

    tabPanel("Network meta-analysis explorer",
      sidebarLayout(
        sidebarPanel(
          selectInput("reference", "Reference treatment", choices = all_treatments, selected = "Placebo"),
          helpText("Network built from published arm-level results of STEP 1, STEP 8, ",
                   "SURMOUNT-1 and SURMOUNT-5 (see README for citations and the shared SD assumption).",
                   "Fixed-effect GLS network model — see R/nma_helpers.R.")
        ),
        mainPanel(
          h4("Forest plot vs selected reference"),
          plotOutput("nma_forest", height = "320px"),
          h4("SUCRA ranking"),
          DTOutput("nma_sucra"),
          h4("League table (row minus column, 95% CI, percentage points)"),
          DTOutput("nma_league")
        )
      )
    )
  )
)

server <- function(input, output, session) {

  ss_plan <- reactive({
    plan_sample_size(delta = input$delta, sd = input$sd, power = input$power,
                      alpha = input$alpha, ratio = input$ratio, dropout = input$dropout,
                      min_active = input$min_active, min_control = input$min_control)
  })

  output$ss_table <- renderTable({
    p <- ss_plan()
    # Pre-format every column to a fixed-width string ourselves: a single
    # global `digits=` on renderTable would otherwise round power=0.90 and
    # alpha=0.05 down to a misleading 1/0.
    data.frame(
      delta = sprintf("%.1f", p$delta),
      sd = sprintf("%.1f", p$sd),
      power = sprintf("%.2f", p$power),
      alpha = sprintf("%.2f", p$alpha),
      ratio = sprintf("%.1f", p$ratio),
      dropout = sprintf("%.2f", p$dropout),
      efficacy_driven_control = format(round(p$efficacy_driven_control), big.mark = ","),
      efficacy_driven_active = format(round(p$efficacy_driven_active), big.mark = ","),
      safety_floor_control = format(round(p$safety_floor_control), big.mark = ","),
      safety_floor_active = format(round(p$safety_floor_active), big.mark = ","),
      final_control = format(round(p$final_control), big.mark = ","),
      final_active = format(round(p$final_active), big.mark = ","),
      final_total = format(round(p$final_total), big.mark = ","),
      binding_constraint = p$binding_constraint,
      check.names = FALSE
    )
  })

  output$ss_message <- renderText({
    p <- ss_plan()
    sprintf("Final planned N = %d (control) + %d (active) = %d, driven by %s.",
            p$final_control, p$final_active, p$final_total, p$binding_constraint)
  })

  output$ss_plot <- renderPlot({
    deltas <- seq(2, 20, by = 0.5)
    tab <- scenario_table(deltas, sd = input$sd, power = input$power, alpha = input$alpha,
                           ratio = input$ratio, dropout = input$dropout,
                           min_active = input$min_active, min_control = input$min_control)
    safety_total <- input$min_active + input$min_control
    ggplot(tab, aes(x = delta)) +
      geom_line(aes(y = efficacy_driven_control + efficacy_driven_active, color = "Efficacy-driven total N"), linewidth = 1) +
      geom_hline(aes(yintercept = safety_total, color = "FDA safety floor (total)"), linewidth = 1, linetype = "dashed") +
      geom_vline(xintercept = input$delta, linetype = "dotted", color = "grey40") +
      scale_color_manual(values = c("Efficacy-driven total N" = "#3B6E8F", "FDA safety floor (total)" = "#C0392B")) +
      labs(x = "Assumed placebo-adjusted effect (percentage points)", y = "Total N",
           color = NULL, title = "Efficacy-driven N vs. FDA safety floor, by assumed effect size") +
      theme_minimal(base_size = 12) + theme(legend.position = "top")
  })

  net_fit <- reactive({
    net <- build_network(armdata, reference = input$reference)
    fit_nma(net)
  })

  output$nma_forest <- renderPlot({
    fd <- forest_data(net_fit())
    fd$treatment <- factor(fd$treatment, levels = fd$treatment[order(fd$estimate)])
    ggplot(fd, aes(x = estimate, y = treatment)) +
      geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
      geom_errorbarh(aes(xmin = lower, xmax = upper), height = 0.15) +
      geom_point(size = 2.5) +
      labs(x = paste0("% body weight change vs ", input$reference, " (pp, 95% CI)"), y = NULL) +
      theme_minimal(base_size = 12)
  })

  output$nma_sucra <- renderDT({
    sc <- sucra(net_fit())
    sc$sucra <- round(sc$sucra, 3); sc$p_best <- round(sc$p_best, 3); sc$mean_rank <- round(sc$mean_rank, 2)
    datatable(sc, rownames = FALSE, options = list(dom = "t", pageLength = 10))
  })

  output$nma_league <- renderDT({
    lt <- league_table(net_fit())
    datatable(as.data.frame(lt), options = list(dom = "t", scrollX = TRUE))
  })
}

shinyApp(ui, server)
