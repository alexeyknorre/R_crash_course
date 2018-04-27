# Код для мастер-класса по анализу данных в R
# ТГУ, Томск, весна 2018
# Алексей Кнорре

# День 2

### Чистка данных

# Устанавливаем нужные нам пакеты
install.packages(c("readxl","dplyr","openxlsx"))

# Данные Агентства по водным ресурсам США
# Прочитываем файл
df <- read.csv("data/course_NWISdata.csv", stringsAsFactors = FALSE)

# Что там внутри?
str(df)

# Верхние 6 наблюдений
head(df)

# Названия переменных
names(df)
# site_no - идентификатор места
# dateTime - дата и время снятия показаний 
# Flow_Inst - объём проходящей воды
# Flow_Inst_cd - как были получены данные?

unique(df$Flow_Inst_cd)
# A e - approved estimated
# A - approved
# X - error
# E - estimated

# Wtemp_Inst - температура воды в градусах Цельсия
# pH_Inst - кислотность воды 
# DO_Inst - содержание кислорода в воде

# Задачка:
# Как узнать, сколько уникальных мест есть в данных?



## Базовый способ отбора данных
# Отобрать только те показания, где температура воды больше 15 градусов
df_high_temp <- df[df$Wtemp_Inst > 15,]
head(df_high_temp)

# 
df_estimated <- df[df$Flow_Inst_cd == "E",]
head(estimated_q)

# И то, и другое сразу
# В чём разница между ними?
df_both <- df[df$Wtemp_Inst > 15 & df$Flow_Inst_cd == "E",]
df_both <- df[df$Wtemp_Inst > 15 | df$Flow_Inst_cd == "E",]

## Отбор данных с помощью dplyr
# Подгружаем библиотеку
library(dplyr)

# Немного другой и более понятный синтаксис

# filter: отбор наблюдений по условию
dplyr_high_temp <- filter(df, Wtemp_Inst > 15)
head(dplyr_high_temp)

df_high_temp <- df[df$Wtemp_Inst > 15 & !is.na(df$Wtemp_Inst) ,]

# Сравниваем количество строк в обоих файлах
nrow(df_high_temp)
nrow(dplyr_high_temp)

# Отбраем те наблюдения, где Flow_Inst_cd == "E"
dplyr_estimated_q <- filter(df, Flow_Inst_cd == "E")
head(dplyr_estimated_q)

# select: отбор переменных
dplyr_sel <- select(df, site_no, dateTime, DO_Inst)
head(dplyr_sel)

# mutate: создание новых переменных из старых

df_newcolumn <- mutate(df, DO_mgmL = DO_Inst/1000)
head(intro_df_newcolumn)

# arrange: сортировка по переменным
# сортируем по росту кислотности
df_arrange <- arrange(df, pH_Inst)
head(df_arrange)

# сортируем по убыванию кислотности
df_arrange <- arrange(df, desc(pH_Inst))
head(df_arrange)

# сортируем по убыванию кислотности, а потом - температуры
df_arrange <- arrange(df, desc(pH_Inst), desc(Wtemp_Inst))
head(df_arrange)

# recode: перекодировка значений
df_recode <- df
unique(df_recode$Flow_Inst_cd)

df_recode$Flow_Inst_cd <- recode(df$Flow_Inst_cd,
                                 "E"="Расчётное",
                                 "A" = "Точное",
                                 "X" = "Ошибочное",
                                 "A e" = "Точное расчётное")
unique(df_recode$Flow_Inst_cd)
head(df_recode)

# rename: переименование переменных
df_rename <- rename(df, 
                   Flow = Flow_Inst,
                   Flow_cd = Flow_Inst_cd,
                   Water_temp = Wtemp_Inst,
                   pH = pH_Inst,
                   DO = DO_Inst)

## Соединяем всё вместе:
## Хотим посмотреть на тёплые потоки воды с точными измерениями:

# Отбираем переменные
df_dplyr <- select(df, site_no, Flow_Inst, Flow_Inst_cd, Wtemp_Inst, pH_Inst)
# Переименовываем их
df_dplyr <- rename(df_dplyr,
                   flow = Flow_Inst,
                   flow_v = Flow_Inst_cd,
                   water_temp = Wtemp_Inst,
                   ph = pH_Inst)
# Перекодируем значения
df_dplyr$flow_v <- recode(df_dplyr$flow_v,
                                 "E"="Расчётное",
                                 "A" = "Точное",
                                 "X" = "Ошибочное",
                                 "A e" = "Точное расчётное")
# Отберём только те наблюдения, где наблюдение точное
df_dplyr <- filter(df_dplyr, flow_v == "Точное")
# Отсортируем по температуре
df_dplyr <- arrange(df_dplyr, desc(water_temp))
head(df_dplyr)

## Пайплайн (pipe)
# Всё выше можно переписать проще

# Идея конвейера: эти две строчки дают один и тот же результат
head(df)
df %>% head()

summary(df)
df %>% summary()

# Перепишем с помощью пайплайна:
#Переменная df_dplyr - это результат следующих действий с df:
df_dplyr <- df %>% 
  # отбираем переменные
  select(site_no, Flow_Inst, Flow_Inst_cd, Wtemp_Inst, pH_Inst) %>% 
  # потом переименовываем их
  rename(flow = Flow_Inst,
         flow_v = Flow_Inst_cd,
         water_temp = Wtemp_Inst,
         ph = pH_Inst) %>% 
  # потом перекодируем
  mutate(flow_v = recode(flow_v,
         "E"="Расчётное",
         "A" = "Точное",
         "X" = "Ошибочное",
         "A e" = "Точное расчётное")) %>% 
  # потом отбёрем только точные наблюдения
  filter(flow_v == "Точное") %>%
  # потом отсортируем - а результат запишем (в начале)
  arrange(desc(water_temp))
  
# Давайте сохраним это
write.csv(df_dplyr, "results/df_dplyr_csv.csv")
# Тоже csv, но хорошо читается Экселем в Windows 
write.csv2(df_dplyr, "results/df_dplyr_csv2.csv")

# Запишем в Эксель:
library(openxlsx)
write.xlsx(df_dplyr, "results/df_dplyr_excel.xlsx")

# Задача:
# переменная flow рассчитана в кубических футах
# Создать новую переменную flow_m, которая будет в кубических метрах.
# Подсказка: в одном метре 3,28 фута.
# Используйте функцию mutate.

df %>% 
  select(site_no, Flow_Inst, Flow_Inst_cd, Wtemp_Inst, pH_Inst) %>% 
  rename(flow = Flow_Inst,
         flow_v = Flow_Inst_cd,
         water_temp = Wtemp_Inst,
         ph = pH_Inst) %>% 
  mutate(flow_v = recode(flow_v,
                         "E"="Расчётное",
                         "A" = "Точное",
                         "X" = "Ошибочное",
                         "A e" = "Точное расчётное")) %>% 
  filter(flow_v == "Точное") %>%
  arrange(desc(water_temp)) %>% 
  #добавьте новую строчку сюда
  mutate(???) %>% 
  #
  write.csv2(.,"results/df_new_column.csv")

### Пример с данными МинЗдрава РФ

library(readxl)
# http://www.gks.ru/free_doc/2017/demo/t3_3.xls
deaths <- read_excel("data/deaths-in-russia-2017.xls")

deaths_clean <- deaths %>% 
  slice(-c(1:7, 9:11, 13, 14, 17, 21:23, 27, 29, 38)) %>% 
  select(1:2) %>% 
  setNames(c("cause","number")) %>% 
  mutate(cause = gsub("из них от|в том числе от|1)|\\:", "", cause),
         number = as.numeric(number)) %>% 
  arrange(desc(number))

write.csv2(deaths_clean, "results/deaths_clean_csv2.csv", row.names = T)
write.xlsx(deaths_clean, "results/deaths_clean_xlsx.xlsx")
###

