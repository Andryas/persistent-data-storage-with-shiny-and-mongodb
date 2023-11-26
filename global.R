library(shiny)
library(mongolite)

conn <- mongo(
  collection = "bookmarking",
  db = Sys.getenv("MONGO_DATABASE"),
  url = Sys.getenv("MONGO_URI")
)
