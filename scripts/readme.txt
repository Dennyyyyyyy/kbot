Після виправлення помилое та рефакторінгу було внесено наступні зміни:

- Застосовано більш консистентні та зрозумілі імена змінних
- Додано функцію для виведення інформації про використання у випадку неправильної кількості аргументів
- Виведення заголовку відокремлено від виведення статистики, щоб він виводився тільки один раз
- Створені функції для виведення інформації про використання та заголовок

Плагін треба покласти у ваш PATH, звідти робимо виклик:

kubeplugin3 kube-system po --sort-by=cpu

, також можна додати необхідні опції, наприклад сортування по CPU
kubeplugin3 kube-system po --sort-by=cpu