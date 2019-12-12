# Set the working directory and list all csv files inside
# Define UI for dataset viewer application
shinyUI(pageWithSidebar(
  # Application title
  headerPanel("Welcome lazy student! You're currently using the program
              'What Nicolas's teacher wants' "),

  # Left hand side panel
  sidebarPanel(
    h2("Data importation"),

    # Button to import data
    fileInput('file1', 'Choose CSV/TXT File',
              accept=c('text/csv', 'text/comma-separated-values,text/plain')),
    # Various checkboxes and input fields to specify the data file format
    checkboxInput('header', ' Header?', TRUE),
    checkboxInput('rownames', ' Row names?', FALSE),
    selectInput('sep', 'Separator:',
                c(Comma=',',Semicolon=';',Tab='\t', Space=' '), 'Comma'),
    selectInput('quote', 'Quote:',
                c(None='','Double Quote'='"','Single Quote'="'"),
                 'Double Quote'),
    selectInput('dec', 'Decimal mark', c(Dot='.', Comma=','), 'Dot'),
    br(),
    # Simple texts
    p(HTML("Get the sources on <b>github</b>:<br />
           <span style='font-size:12px;font-family:courrier;
           background-color:#FADDF2;border:1px solid black;'>
           <font color='#870500'><b>git clone
           https://github.com/tuxette/wnaetw.git</b></font></code></span>")),
    p(HTML("This application is kindly provided by
           <a href='http://tuxette.nathalievilla.org'><font color='#DF01A5'>
           <b>Natty</b></font></a> with the generous help of
           <font color='#3E2D8E'><b>Nicholas</b></font>,
           <font color='#159332'><b>Arthur P.</b></font> and
           <font color='#159332'><b>John</b></font> ;-). It is distributed under
           the licence <a href='http://www.wtfpl.net/'>WTFPL</a>."))
  ),

  # Main panel (on the right hand side)
  mainPanel(
    tabsetPanel(
      tabPanel("Data",
               h3("Basic user guide"),
               p(HTML("To run the application, import your data set using the
                       import button on the left hand side panel. You data must
                       be supplied on the form of a text/csv file. An example
                       of a properly formatted file is provided at <a href=
'http://owncloud.nathalievilla.org/apps/files_sharing/get.php?token=a4ccfca90d9c7928ceb6153929d4212bd90badc5'
                       >here</a> (it contains simple data on my former
                       first-year students): this file is formatted using the
                       default options of the left panel. If the importation is
                       done properly, the data are displayed on the main panel
                       and analyzed on the two other panels.")),
               p(HTML("<b><div style='background-color:#FADDF2;border:1px solid
                       black;'>Warning! 'wnaetw' is a free program provided
                       without any guarantee: please note that it does not
                       replace your brain. In particular, the dev team is not
                       responsible if a lazy student is not able to interpret
                       the function's outputs properly!!! (and if he thinks
                       that an average zip code is somehow informative...)</div>
                       </b>")),br(),
               h3("The dataset you want to use is displayed below:"),
               p("(only the first 50 first rows if the dataset contains more
                  than 50 rows, and the first 10 columns if the dataset contains
                  more than 10 columns)"),
               tableOutput("view")
      ),

      # Numerical summary of the dataset,
      # coming from the function output$summary in server.R
      tabPanel("Summary",downloadButton('downloadSummary', 'Download Summary'),
               br(),br(),tableOutput("summary")),

      # Graphic
      # coming from the function output$boxplots in server.R
      tabPanel("Boxplots",
               textInput("main",strong("Graphic title:"), "Boxplots"),
               textInput("xlab",strong("X axis label:"), "Variables"),
               textInput("ylab",strong("Y axis label:"), ""),
               textInput("color","Color:","pink"),
               checkboxInput(inputId = "scale", label = " Scale variables?",
                             value = TRUE),
               plotOutput("boxplots")
      )
  ))
))

source("scripts/scripts.R")
library(e1071)
library(ineq)

shinyServer(function(input, output) {
  # Function that imports the data file
  dInput = reactive({
    in.file = input$file1

    if (is.null(in.file))
      return(NULL)

    if (input$rownames) {
      read.table(in.file$datapath, header=input$header, sep=input$sep,
               quote=input$quote, row.names=1, dec=input$dec)
    } else {
      read.table(in.file$datapath, header=input$header, sep=input$sep,
                 quote=input$quote, dec=input$dec)
    }
  })

  # Function that render the data file and passes it to ui.R
  output$view = renderTable({
    d.input = dInput()
    if (is.null(d.input)) return(NULL)
    if (ncol(d.input>10)) d.input = d.input[,1:10]
    head(dInput(), n=50)
  })

  # Function that calculates the output sent to the main panel in ui.R
  output$summary = renderTable({
    d.input = dInput()
    t(apply.wmtw(d.input))
  })

  # Function that creates a download button
  output$downloadSummary = downloadHandler(
    filename = "summary.csv",
    content = function(file) {
      write.csv(apply.wmtw(dInput()), file)
  })

  # Function that makes a boxplot for the numeric variables in the data set
  output$boxplots = renderPlot({
    make.boxplot(dInput(),main=input$main,xlab=input$xlab,ylab=input$ylab,
                 scale=input$scale, col=input$color)
  })
})


runApp("PATH-TO-R-PACKAGE/inst/shiny-WUI/")
