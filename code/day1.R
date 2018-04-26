# Код для мастер-класса по анализу данных в R
# ТГУ, Томск, весна 2018
# Алексей Кнорре

# День 1

# R как калькулятор

2 + 2
56 * 32
45 ^ 55

# Переменные

x <- 7
x * 10

# Строки

hello <- "Привет, меня зовут "
name <-"_впишите_сюда_имя_"

# Функции

paste0(hello, name)


# Повторение переменной x 10 раз:

rep(x, 10)
rep(name, 10)

# Создание последовательности чисел:

seq(1,10)
seq(5,9)
seq(3,9) * 3

# Помощь по функции seq:
help(seq)

# Векторы
height <- c(145, 167, 176, 123, 150)
height

weight <- c(51, 63, 64, 40, 55)
weight

#  Датафреймы

data <- data.frame(weight, height)
data
data$weight

# Вычисляем среднее:
mean(data$weight)
mean(data$height)

# Напишем свою функцию:
our.mean <- function(x){
  return(sum(x) / length(x))
}

our.mean(data$weigth)


# Как коррелируют вес и рост:
cor(data$weight, data$height)

# Таблица сопряженности:
table(data$weight, data$height)

### Данные института проблем правоприменения об арбитражных судебных решениях
commercial_courts_cases <- read.csv("https://github.com/alexeyknorre/Rbitrazh/raw/master/IRL_commcourts_decisions_cp1251.csv",
                                    stringsAsFactors = FALSE)
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

