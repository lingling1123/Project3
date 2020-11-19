#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
library(dplyr)
library(tree)
library(tidyverse)
library(caret)
library(plotly)
data<-read.csv('https://raw.githubusercontent.com/lingling1123/covid-19-data/master/us-states.csv')
data<-data%>%filter(state=='North Carolina')
data$month<-c()
data$days_to_first_case<-as.numeric(as.Date(data$date,origin='2020-03-03'))-(18281+42)
cases<-data$cases
deaths<-data$deaths
data$date <- as.Date(data$date, format = "%Y-%m-%d")
for(i in 1:nrow(data)){
    if(i<=29){
        data$month[i]='Mar'
    }else if(i>29 & i<=59){
        
        data$month[i]='Apr' 
    }else if(i>59 & i<=90){
        
        data$month[i]='May' 
    }else if(i>90 & i<=121){
        
        data$month[i]='Jun' 
    }else if(i>121 & i<=152){
        
        data$month[i]='Jul' 
    }else if(i>152 & i<=182){
        
        data$month[i]='Aug' 
    }else if(i>182 & i<=212){
        
        data$month[i]='Sep' 
    }else if(i>212 & i<=243){
        
        data$month[i]='Oct' 
    }else if(i>243 & i<=256){
        
        data$month[i]='Nov' 
    }
}
data$month<-as.factor(data$month)


# Define server logic required to draw a histogram
shinyServer(function(input,output,session) {
    # Information section
    
    
    # Summary 
    output$header<-renderUI({
        test<-paste0('Investigation of ',input$var)
        h1(test)
    })
    
    value<-reactive({
        a<-data%>%select(input$var)
        if(input$var=='cases'){
            ggplot(a,aes(x=cases/1000))+geom_histogram(binwidth=10)
        }else{
            ggplot(a,aes(x=deaths/1000))+geom_histogram(binwidth=0.3)
        }  
    })
    
    output$plot<- renderPlotly({
        ggplotly(value())
    })
    output$save <- downloadHandler(
        file = "save.png" , 
        content = function(file) {
            png(file = file)
            p2()
            dev.off()
        })
    
    
    output$table<-renderTable({
        a<-select(data,input$var)
        a_<-as.data.frame(summary(a))
        a_[,3]
        
    })
    
    # Analysis
    selectedData <- reactive({
        if(input$var2=='deaths&days_to_first_case'){
            data[,c('deaths','days_to_first_case')]
        }else if(input$var2=='days_to_first_case&cases'){
            data[,c('cases','days_to_first_case')]
        }else if(input$var2=='deaths&cases'){
            data[,c('deaths','cases')]
        }
        
    })
    
    output$analysisPlot<-renderPrint({
        PCs<-prcomp(selectedData(),scale = TRUE)
        PCs
        
    })
    output$analysisPlot2<- renderPlot({
        
        PCs<-prcomp(selectedData(),scale = TRUE)
        biplot(PCs,xlabs=data$month,cex=0.5,expand=1)
    })
    
    
    
    # model
    #y is death
    trainIndex <- createDataPartition(data$deaths, p = 0.7, list = FALSE)
    cvTrain <- data[trainIndex, ]
    cvTest <- data[-trainIndex, ]
    
    
    try1<-reactive({
        x<-select(data,input$x,deaths)
        fit<-lm(deaths~.,x)
        fit
    })
    
    predvar<-reactive({
        a<-input$predvar
        x<-select(data,input$x,deaths)
        fit<-lm(deaths~.,x)
        if(input$x=='cases'){
            predict(fit,newdata=data.frame(cases=a), type = "response", se.fit = TRUE)
        }else{
            predict(fit,newdata=data.frame(days_to_first_case=a), type = "response", se.fit = TRUE)
        }
        
    })
    
    
    output$modelPlot<-renderPrint({
        try1()
        
    }
    )
    
    
    
    output$equation<-renderUI({
        if(input$x=='cases'){
            withMathJax(
                helpText('$$Y \\ = 207.53305+0.01538X $$')
            )
        }else if(input$x=='days_to_first_case'){
            withMathJax(
                helpText('$$Y \\ = -702.41+19.48X $$')
            )
        }
    })
    
    
    output$predict<-renderPrint({
        predvar()
        
    }
    )
    
    
    
    
    
    
    tab2 <- reactive({
        x<-cvTrain[,input$xcol]
        y<-cvTrain$deaths
        treeFit <- tree(y~x,data)
        plot(treeFit)
        text(treeFit)
        
    })
    
    
    output$modelPlot2<-renderPlot({
        tab2()
        
    }
    )
    
    
    
    #data
    
    output$datatable<-renderTable({
        if(input$set){
            if(input$subvar =='month'){
                newdata <- filter(data, month==input$number)
                newdata
            }else if(input$subvar=='date'){
                newdata<-filter(data, date==input$date1)
                newdata
            }
        }else{
            newdata<-data
            newdata
        }
        
    })
    
    output$downloadData <- downloadHandler(
        filename = function() {
            if(input$set==1){
                paste(input$set, ".csv", sep = "")
                if(input$set2=='Deaths more than 4k'){
                    paste(input$set2, ".csv", sep = "")
                }
            }
        },
        content = function(file) {
            write.csv(newtable(), file, row.names = FALSE)
        }
    )
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
)

