#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(plotly)


# Define UI for application that draws a histogram
shinyUI(navbarPage('All you can know!',
                   
                   # Information
                   tabPanel('Information',
                            sidebarPanel(
                                h4('The outbreak of Covid-19 influences lot of things. I would like to use daliy Covid-19 dataset to make an exposure notification APP for North Carolina. '),
                                h4('Data in this app is ',a("Covid-19", href="https://github.com/lingling1123/covid-19-data/blob/master/us-states.csv")),
                                h4('Consideirng that first record of NC from this source was on march 3rd. I do some manupilation to dataset and make it to have 7 variables at last. They are seperately:'),
                                h4('Date : record date from 2020-03-03 up to 2020-11-13  '),
                                h4('Dtate : NC'),
                                h4('Fips: country fips code '),
                                h4('Cases: cumulative cases ')  , 
                                h4('Deaths: deaths number   ') ,
                                h4('Days to fist case(start form Mar 03): days from now to 2020-03-03'),
                                h4('Month: month from March to Nov '),
                                h4('I will use this dataset to do numeric and graphical summaries to show comulative deaths and cases of NC,make models on variable deaths, and do some predictions. Hope to remind people how serious Covid-19 is by visualizing results.')
                            )
                   ),
                   
                   # Summaries
                   tabPanel('Summaries',
                            uiOutput('header'),
                            sidebarLayout(
                                sidebarPanel(
                                    
                                    radioButtons('var',h5('Select the variable '),choices=list('cases','deaths')),
                                    h4('You can get numerical summaries for each month below.')
                                    
                                ),
                                # Show a plot of the generated distribution
                                mainPanel(
                                    
                                    plotlyOutput('plot'),
                                    downloadButton("save", "save"),
                                    tableOutput("table")
                                )
                            )
                   ),
                   
                   # Analysis
                   tabPanel('Analysis',
                            sidebarLayout(
                                sidebarPanel(
                                    h3('Principal Components Analysis'),
                                    selectInput("var2", h4("Choose variables that you want to investigate"),choices=c('deaths&days_to_first_case','days_to_first_case&cases'),selected=c('deaths&days_to_first_case')),
                                    
                                ),
                                # Show a plot of the generated distribution
                                mainPanel(
                                    verbatimTextOutput("analysisPlot"),
                                    plotOutput("analysisPlot2")
                                )
                            )
                   ),
                   
                   navbarMenu("Model",
                              tabPanel("Simple Linear Regression",
                                       sidebarLayout(
                                           sidebarPanel(
                                               h4('We will predict deaths number via values of other variables through SLR'),
                                               selectInput('x', 'X Variable to fit model', choices=c('days_to_first_case','cases'),selected = 'cases'),
                                               numericInput('predvar','Enter a number to predict',value=0,min=0,max=100)
                                               
                                           ),
                                           mainPanel(
                                               verbatimTextOutput("modelPlot"),
                                               withMathJax(),
                                               helpText( 'The linear regression equaion is'),
                                               uiOutput("equation"),
                                               verbatimTextOutput("predict")
                                               
                                           )
                                       )   
                              ),
                              tabPanel("Basic Tree",
                                       sidebarLayout(
                                           sidebarPanel(
                                               h4('We will predict deaths number via values of other variables through tree model '),
                                               selectInput('xcol', 'X Variable', choices=c('days_to_first_case','cases','month'),selected = 'cases'),
                                               numericInput('predvar2','Enter a number to predict',value=0,min=0,max=100)
                                           ),
                                           mainPanel(
                                               
                                               plotOutput("modelPlot2"),
                                               verbatimTextOutput("predict2")
                                               
                                           )
                                       )   
                              )
                   ),
                   
                   tabPanel('Data',
                            sidebarLayout(
                                sidebarPanel(
                                    h3('You can look whole data here!'),
                                    checkboxInput('set','Want to see subset?'),
                                    conditionalPanel(
                                        condition = 'input.set = 1',
                                        selectInput('subvar','Which  variable you want to subset in the data?',choices=c('month','date'),selected = 'month'),
                                        conditionalPanel(
                                            condition="input.subvar== 'month'",
                                            radioButtons('number','Month that you want to check',choices = c('Mar','Apr'),selected = 'Mar')
                                        ),
                                        
                                        conditionalPanel(
                                            condition="input.subvar=='date'",
                                            dateInput('date1','Date that you want to check',value='2020-04-05')
                                            
                                        )
                                    ),
                                    
                                    downloadButton("downloadData", "Download")
                                ),
                                # Show a plot of the generated distribution
                                mainPanel(
                                    tableOutput("datatable")
                                )
                            )
                   )
                   
                   
                   
                   
)
)
