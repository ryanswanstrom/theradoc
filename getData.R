## Web Screen Page Scraper
## Colin A. White | Avera Clinical Intelligence | Sept 2014

getData <- function (view, measure) {
        # Load RCurl helper package
        library(httr)
        # Load the XML/HTML XPath parsing package
        library(XML)
        # Override MS Windows Registry Proxy Settings
        Sys.unsetenv("http_proxy")
        # Identify the target FQDN
        url  <- "http://ahdc372n2.phs-sfalls.amck.net"
        # Assign results of HTTP POST operation to Authenticate
        login <- POST(url, body=list(username="foo", password="bar"), 
                      path="theradoc/login/index.cfm" )
        # Make a selection from a dropdown list with an HTTP POST
        results <- POST(url, body=list(name="viewSelectForm252", changeView=view),
                        path="theradoc/index.cfm?view=20616.252" )
        # Parse the returned HTML results (DOM
        code <- htmlParse(results, asText=TRUE, trim=TRUE)
        # Use XML XPath to parse DOM and include/exclude nodes
        plain.text <- xpathSApply(code, "//text()[ancestor::table]
                                [ancestor::div[@id='dashboardContent']]
                                [not(ancestor::script)]
                                [not(ancestor::style)]", xmlValue)
        # Cleanse plain.text with Regex Foo
        data <- gsub("[\r\n\t[:blank:]?]", '', plain.text)
        
        # Assign our clean data to a matrix object
        x <- matrix(nrow=6, ncol=2, byrow=TRUE,
                    c( data[c(25,35)],
                       data[c(37,47)],
                       data[c(49,59)],
                       data[c(61,71)],
                       data[c(73,83)],
                       data[c(85,95)] ) 
        )        
        colnames(x) <- c("Facility", "results")        
        measure <- rep(measure, 6) # Add a measure ID column
        x <- cbind(x, measure)
        
        return(x)
}

getNumerator <- function (x) {
        substr(x, 
               (regexpr("\\[", x)[1])+1, # Match to first square bracket []
               (regexpr("\\/", x)[1])-1  # Match to the first slash /
        )
}

getDenominator <- function (x) {
        substr(x,
               (regexpr("\\/", x)[1])+1, # Match to the first slash /
               (regexpr("\\*", x)[1])-1  # Match to the first star * 
        )
}

numDen <- function(x) {
        Num <- lapply(x[,2], getNumerator)
        x <- cbind(x, Num) # Add Num column back to matrix
        Den <- lapply(x[,2], getDenominator)
        x <- cbind(x, Den) # Add Den column back to matrix
        rowupdatetime <- rep(format(Sys.time(), "%a %b %d %X %Y"), 6)
        x <- cbind(x, rowupdatetime) # Add a row date time stamp        
        return(x) # Return the combined matrix
}