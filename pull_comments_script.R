library(jsonlite);library(dplyr)

docket_id <- "EPA-HQ-ORD-2013-0189"

dir.create(docket_id)

system(paste0('curl -H "Content-Disposition:attachment; filename=DOCKET_', docket_id, '.csv" https://www.regulations.gov/ecomment_tableportdocket?docketId=', docket_id,  ' > ', 
              docket_id, '.csv'))

comment_table <- read.csv(paste0(docket_id, '.csv'), skip = 5)

comment_table <- comment_table %>% select(Document.ID, Attachment.Count) %>% 
  mutate(Attachment.Count = as.character(Attachment.Count)) %>%
  filter(Attachment.Count != "N/A") %>%
  mutate(Attachment.Count = as.numeric(Attachment.Count))

# number of attachements
sum(comment_table$Attachment.Count)

# attachment download counter, z.
z <- 1

dir.create(docket_id)

for(i in 1:nrow(comment_table)) {
  doc <- comment_table[i,]
  for(j in 1:doc$Attachment.Count)
    GET(paste0("https://www.regulations.gov/contentStreamer?documentId=",
               doc$Document.ID, "&attachmentNumber=", j ,"&disposition=attachment&contentType=pdf"), 
        write_disk(paste0("/home/ht/Desktop/", docket_id, "/", doc$Document.ID, "-", j, ".pdf")), overwrite=TRUE)
  z <- z + 1
  print(z)
}