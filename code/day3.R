# Код для мастер-класса по анализу данных в R
# ТГУ, Томск, весна 2018
# Алексей Кнорре

# День 3

install.packages(c("xml2","rvest", "stringdist", "ggvis", "readxl", "reshape2", "ggplot2", "scales", "dplyr"))

library(rvest)

# Сотрудники кафедры социологии ФСФ ТГУ
staff <- read_html("http://fsf.tsu.ru/chairs/sociology/staff/") %>% 
  html_nodes(".staff") %>% html_text()

staff

# Учебные программы кафедры
programs <- read_html("http://fsf.tsu.ru/programs/sociology/") %>%
  html_nodes(".entry-content a") %>% 
  html_attr("href")

programs

# Создадим папку
dir.create(file.path("results", "programs"), showWarnings = FALSE)

# Скачиваем программы
for (url in programs) {
  download.file(url,
    destfile = file.path("results/programs", basename(url)),
    mode = "wb")
}

### Немного визуализации данных
library(dplyr)
library(ggplot2)

df <- readxl::read_excel("data/deaths-in-russia-2017.xls") %>% 
  slice(-c(1:7, 9:11, 13, 14, 17, 21:23, 27, 29, 38)) %>% 
  select(1:2) %>% 
  setNames(c("cause","number")) %>% 
  mutate(cause = gsub("из них от|в том числе от|1)|\\:", "", cause),
         number = as.numeric(number))

p <-  ggplot(df, aes(y = number, x = reorder(cause,number))) +
  geom_bar(stat = "identity") +
  coord_flip() +
  geom_text(aes(label=paste(
    substr(number, 0, nchar(number)-3),
    "тыс.")), hjust = -0.2) +
  labs(x = "",
       y = "Число умерших",
       title = "Статистика смертности россиян в 2017 году.\nСмерть наступила от...",
       caption = paste0("Источник: данные Росстата о причинах",
                        " смертности россиян в 2017 году\nURL",
                        ": http://www.gks.ru/free_doc/2017/demo/t3_3.xls")) +
  ylim(0,600000) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(hjust = 0.5),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())

ggsave(p, width = 12, height = 6, dpi = 500, filename = "results/deaths-in-russia-2017.png")


#### Большая история про самый убийственный регион
### Готовим данные по населению

wiki_url <- "https://ru.wikipedia.org/wiki/%D0%A1%D1%83%D0%B1%D1%8A%D0%B5%D0%BA%D1%82%D1%8B_%D0%A0%D0%BE%D1%81%D1%81%D0%B8%D0%B9%D1%81%D0%BA%D0%BE%D0%B9_%D0%A4%D0%B5%D0%B4%D0%B5%D1%80%D0%B0%D1%86%D0%B8%D0%B8"

# XPath, который мы вручную взяли из исходного кода HTML-страницы
wiki_xpath <- '//*[@id="mw-content-text"]/div/table[4]'

wiki_table <- wiki_url %>% read_html() %>% html_node(xpath = wiki_xpath) %>% html_table()

# Оставляем нужные колонки
wiki_table <- wiki_table[,c(2,5,6)]

## Чистим таблицу
# Переименовываем колонки
names(wiki_table) <- c("region", "area", "population")
# Убираем строки с NA 
wiki_table <- wiki_table[complete.cases(wiki_table),]
# Делаем нормальный столбец с населением
wiki_table$population <- as.numeric(gsub("[^0-9\\.]", "", wiki_table$population))
# Удаляем строку с Российской Федерацией
wiki_table <- wiki_table[!grepl("Российская Федерация", wiki_table$region),]


### Готовим данные по преступности

# Прочитываем xml
crimes_xml <- read_xml("data/crimestat_105+.xml")
# Извлекаем всё, что находится под нодами <row>:
rows <- html_nodes(crimes_xml,  xpath = "//row/*")

# Это названия значений:
head(xml_name(rows))
# Это сами значения
head(xml_text(rows))

# Сохраняем в матрицу, не трогая названия значений - они тут не нужны.
# При переводе в матрицу говорим, чтобы делал это по строкам (byrow = T, иначе
# путается порядок), и эксплицитно задаём 4 колонки:
crimes <- matrix(xml_text(rows), byrow = T, ncol = 4)
head(crimes)

# Теперь в родной датафрейм
crimes <- data.frame(crimes, stringsAsFactors = F)
names(crimes) <- c("crimes", "period_start", "region", "period_end")

# Оставим только 2016 год:
crimes <- crimes[which(crimes$period_start == "2016-01-01" &
                         crimes$period_end == "2016-12-01"),]

# И выкидываем периоды, они больше не нужны:
crimes$period_start <- NULL
crimes$period_end <- NULL

# Приводим в порядок тип переменной:
crimes$crimes <- as.numeric(crimes$crimes)
# Убираем всю Россию и федеральные округа
crimes <- crimes[!grepl("Российская Федерация|+ФО+", crimes$region),]


### Объединяем данные

nrow(crimes)
nrow(wiki_table)
# Фух, сходится.


### Проблема: имена регионов разные. Что делать?

data.frame(crimes = crimes$region, wiki = wiki_table$region)

#######################################
# <<< FUCK YEA FUZZY MATCHING!!! >>>  #
#######################################

#install.packages("stringdist")
library(stringdist)



## Идея: автоматический подбор наиболее похожей строки:

# Для Республики Саха-Якутия из регионов по преступлениям...
crimes$region[1]

# Высчитываем близость всех других регионов из википедии...
dists <- stringdist(crimes$region[1], wiki_table$region)
dists

# Делаем это красиво и наглядно...
names(dists) <- wiki_table$region
# Чем меньше distance, тем более похожа строка
data.frame(distance = dists[order(dists)])

## Важно максимально очистить названия, чтобы машина всё смогла:
# Убираем слово "Республика" (для фаззи матчинга)
crimes$region <- gsub("Республика", "", crimes$region)

# Удаляем скобки с цифрами
wiki_table$region <- gsub("\\[|\\]|[0-9]", "", wiki_table$region)

## теперь можно и цикл сделать!

# Создаём пустую переменную для матчинга имени другого региона
crimes$wiki_region_match <- NA

for (i in 1:nrow(crimes)){
  dists <- stringdist(crimes$region[i], wiki_table$region)
  names(dists) <- wiki_table$region
  crimes$wiki_region_match[i] <- names(dists[order(dists)][1])
}

### Готово. Объединяем данные:

df <- merge(crimes, wiki_table, by.x = "wiki_region_match", by.y = "region")

# Убираем ненужные колонки:
df <- subset(df, select = -c(region) )
names(df)[1] <- "region"

# Сохраняем
write.csv(df, "results/murder_crimes_by_regions.csv", row.names = F)


