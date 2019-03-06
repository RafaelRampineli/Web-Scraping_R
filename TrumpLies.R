# Estudo de Caso - Extraindo Dados da Web com Web Scraping em R

# Configurando o diretório de trabalho
# Coloque entre aspas o diretório de trabalho que você está usando no seu computador
# Não use diretórios com espaço no nome
setwd("{SET_YOUR_HOME_DIRECTORY_HERE}")
getwd()


# Pacotes R para Web Scraping
# RCurl
# httr
# XML
# rvest

# Pacote rvest - útil para quem não conhece HTML e CSS
install.packages('rvest')
library(rvest)

library(stringr)
library(dplyr)
library(lubridate)
library(readr)

# Leitura da web page - Retorna um documento xml
webpage <- read_html("https://www.nytimes.com/interactive/2017/06/23/opinion/trumps-lies.html")
webpage


# Extraindo os registros
?html_nodes

# É necessário conhecer o html do site para saber oque extrair para realizar a análise
results <- webpage %>% html_nodes(".short-desc") #Extrair tudo oque tiver a tag "short-desc"
results

# Construindo o dataset
# Contém todos o numero de registros obtidos no results
records <- vector("list", length = length(results))
records

?str_c # Concatenar varias strings em uma unica
?str_sub #extrair e substituir substrings de um vetor
?xml_contents
?html_text

# Executar em caso de dúvidas
# str_sub(xml_contents(results[1])[2] %>% html_text(trim = TRUE), 2, -2)

# Percorre o dataset results linha por linha e extrai as informações necessárias
for (i in seq_along(results)) {
  date <- str_c(results[i] %>% 
                  html_nodes("strong") %>% #Procura pela tag strong
                  #Ao encontrar a tag Strong, pega os dados da tag excluindo espaços em branco
                  html_text(trim = TRUE), ', 2017') # 2017 apenas complemento dos dados
  #[2] representa o segundo elemento
  # 2, -2 da função str_sub é para eliminar as " " do conteudo 
  lie <- str_sub(xml_contents(results[i])[2] %>% html_text(trim = TRUE), 2, -2)
  
  explanation <- str_sub(results[i] %>% 
                           #procura pela tag ".short-truth" para pegar todo conteudo da tag, até dependecias
                           html_nodes(".short-truth") %>%  
                           html_text(trim = TRUE), 2, -2)
  
  url <- results[i] %>% html_nodes("a") %>% html_attr("href") #atributo da tag a
  
  # Salva os dados no dataset records em cada elemento do index criado anteriormente
  records[[i]] <- data_frame(date = date, lie = lie, explanation = explanation, url = url)
}

records

# Dataset final
?bind_rows # Junta todas as linhas do objeto que é uma lista 
df <- bind_rows(records)
df

# Transformando o campo data para o formato Date em R
df$date <- mdy(df$date)

# Exportando para CSV
write_csv(df, "mentiras_trump.csv")

# Lendo os dados
df <- read_csv("mentiras_trump.csv")
View(df)

