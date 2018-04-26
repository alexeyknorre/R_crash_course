# Код для мастер-класса по анализу данных в R
# ТГУ, Томск, весна 2018
# Алексей Кнорре

# День 1

# R как калькулятор

2 + 2
56 * 32
45 ^ 55

## Переменные и присвоение

# Число
i <- 23
i

# строка
s <- 'Привет, мир!'
s

# логическое значение (boolean)
b <- TRUE
b

i * 10

## Структуры данных

# вектор
# с() - способ соединить значения в вектор
v <- c(145, 167, 176, 123, 150)
v
# вывести наблюдения 1 и 2
v[1:2]


# датафрейм

years <- c(1980, 1985, 1990)
scores <- c(34, 44, 83)
df <- data.frame(years, scores)
df[,1]
df$years

## control flow

# if-then

a <- 66
  if (a > 55) {
    print("Переменная а больше 55")
} else {
    print("Переменная а меньше или равна 55")
}

# for
mylist <- c(55, 66, 77, 88, 99)
for (value in mylist) {
  print(value)
}

# Функции
hello <- "Привет, меня зовут "
name <-"_впишите_сюда_имя_"
paste0(hello, name)

height <- c(145, 167, 176, 123, 150)
mean(height)
summary(height)


# Напишем свою функцию:
our.mean <- function(x){
  return(sum(x) / length(x))
}

our.mean(height)

# Задача: написать функцию, единственным аргументом
# которой является строка имени, а результатом выполнения -
# строка "Привет, меня зовут [имя]"


# rep: Повторение переменной:

rep(x, 10)
rep(name, 10)

# Создание последовательности чисел:

seq(1,10)
seq(5,9)
seq(3,9) * 3

# Помощь по функции seq:
help(seq)

### Установка пакетов и библиотек
# Функция для установки
install.packages("dplyr")
# Функция для активации пакета
library("dplyr")
# Можно устанавливать несколько пакетов сразу
install.packages(c("readxl","dplyr","ggplot2", "openxlsx","scales"))


### 
# Данные института проблем правоприменения 
# об арбитражных судебных решениях
# 10893 закодированных решения с сайтов арбитражных судов. Случайная выборка из 5 млн. дел за 2007-2011 годы.
commercial_courts_cases <- read.csv("https://github.com/alexeyknorre/Rbitrazh/raw/master/IRL_commcourts_decisions_cp1251.csv",
                                    stringsAsFactors = FALSE)
# Подробная презентация
# http://htmlpreview.github.io/?https://github.com/alexeyknorre/Rbitrazh/blob/master/OpenDataDay_Rbitrazh_Knorre.html


#Используемые переменные
#dec_sum - сумма иска
#date_… - даты принятия иска, первого суда и решения суда
#dec_type - кто заявитель?
#pair - производная переменная, показывающая, кто заявитель (гос.орган или предприниматель) и истец (4 возможных значения)
#regi - регион, в котором рассматривалось дело


str(commercial_courts_cases)


# Работаем с наблюдениями
# показать первое наблюдение
commercial_courts_cases[1,]
# показать первые 10 наблюдений
commercial_courts_cases[1:10,]
# показать первые 10 наблюдений по переменной sum_dec (сумма иска)
commercial_courts_cases[1:10,c("sum_dec")]

# описательная статистика
summary(commercial_courts_cases$sum_dec)

commercial_courts_cases[1:10,c("pair")]
table(commercial_courts_cases$pair)
