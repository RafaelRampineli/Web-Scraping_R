# Web Scraping do Site da Super Bowl


# Configurando o diretório de trabalho
# Coloque entre aspas o diretório de trabalho que você está usando no seu computador
# Não use diretórios com espaço no nome
setwd("{SET_YOUR_DIRECTORY_HERE}")
getwd()

# Formatando os dados de uma página web
library(rvest)
library(stringr)
library(tidyr)

# Caso não tenha as library já instaladas, intalar:
install.packages('rvest')
install.packages('tidyr')


# Realizando a leitura dos dados da superbowl/history/winners e coletando a tag "table"
url <- 'http://espn.go.com/nfl/superbowl/history/winners'
pagina <- read_html(url)

table <- pagina %>% html_nodes("table")

# Convertendo os dados coletados para um data.frame, para melhor manipulação dos registros
class(table)

?html_table
View(table)

dataframe <- as.data.frame(html_table(table))
View(dataframe)
class(dataframe)

# Removendo as 2 primeiras linhas do dataframe e renomeando as colunas

dataframe <- dataframe[-c(1:2),]
View(dataframe)

colnames(dataframe)[] <- c("Number", "Date", "Stadium", "Result_Game")

# Convertendo os algarismos romanos (Coluna Number) para números inteiros

# Exitem 53 linhas no dataframe (ignorando o cabeçalho), podemos atribuir valores de 1:53
# diretamente para a coluna Number. Assim como fizemos para remover 2 linhas, porém agora estamos atribuindo
# valor diretamente a coluna

dataframe$Number <- 1:53 #Deve existir outro modo de fazer
View(dataframe)

# Vamos realizar o split da ultima coluna (Result_Game) que contém informações como: Nome do time e pontos no final da partida.
# Iremos separar os times em 2 novas colunas: TeamA e TeamB

#help da função separate do pacote tidyr
?separate

dataframe_split <- separate(dataframe, Result_Game, into = c("TeamA", "TeamB"), sep = ",")
View(dataframe_split)

# Vamos separar os pontos de cada time em duas novas colunas
?grep

padrao = "\\d+" #Qualquer número e tudo que estive após ele

grep(padrao, dataframe_split$TeamA, value = T)
grep(padrao, dataframe_split$TeamB, value = T)

?gsub
?str_extract

dataframe_split$TeamAPoints = str_extract(dataframe_split$TeamA, padrao)
dataframe_split$TeamBPoints = str_extract(dataframe_split$TeamB, padrao)
dataframe_split$TeamA = gsub(padrao, "", dataframe_split$TeamA)
dataframe_split$TeamB = gsub(padrao, "", dataframe_split$TeamB)

View(dataframe_split)
View(dataframe)

# Salvando o resultado em um arquivo CSV
write.csv(dataframe_split, "SuperBowlWinners", row.names = F) #para excluir o nome das linhas


# Separar a Cidade do Stadium (Caso seja necessário)
var = "[:punct:]"

View(separate(dataframe, Stadium, into = c("Stadium", "City"), sep = var))
