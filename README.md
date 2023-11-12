# kbot
DevOps application from scratch 

https://t.me/Dennyyyyyyy_bot

#ініціалузуємо mod над яким будемо працювати далі
go mod init github.com/Dennyyyyyyy/kbot #вказуємо імʼя репозиторія, go створить файл go.mod де буде зберігати всі модулі кода

#встановимо кодогенератор, потужна бібліотека для створення сучасних cli-додатків 
go install github.com/spf13/cobra-cli@latest 

#згенеруємо початковий код
cobra-cli init #буде створено основний файл main.go, заповнить go.mod, та директорію cmd з root.go де згенеровано початковий код

#згенеруємо код команди version
cobra-cli add version #отримали новий файл version.go

#білд програми, команда run автоматично білдає і запускає код
go run main.go help #як видно код програми help вже інтегровано

#перевіримо команду version
go run main.go version 

#додамо команду яка буде з основним кодом
cobra-cli add kbot

#ця команда динамічно збирає всі компоненти перед білдом (ld - це лінкер), прямо з командного рядка. Параметр -Х присвоєння значення зміним в модулях.
go build -ldflags "-X="github.com/Dennyyyyyyy/kbot/cmd.appVersion=1.0.0 #отримали бінарний файл на імʼя kbot

#запустимо наш kbot
./kbot

#імпортуємо пакет в kbot.go
telebot "gopkg.in/telebot.v3"

#декларуємо зміну TELE_TOKEN
var (
	//name of Telebot
	TeleToken = os.Getenv("TELE_TOKEN")
)

#додамо в блоці хендлера kbot код функції run
fmt.Printf("kbot %s started", appVersion)

#та блок ініціалізації kbot, створення нового боту з параметрами
kbot, err := telebot.NewBot(telebot.Settings{
			URL:    "",
			Token:  TeleToken,
			Poller: &telebot.LongPoller{Timeout: 10 * time.Second},
		})

#наступний блок це блок обробки помилок
if err != nil {
			log.Fatalf("Please check TELE_TOKEN env variable. %s", err)
			return
		}

#обробка події коду Handler-a
kbot.Handle(telebot.OnText, func(m telebot.Context) error {
			log.Print(m.Message().Payload, m.Text())
			payload :=m.Message().Payload

				switch payload {
				case "Hello Denny":
					err = m.Send (fmt.Sprintf("Hello! I`m Kbot %s. How are you up?", appVersion))
					
				}

			return err
		})

#запуск бота
kbot.Start()

#переходимо до тестування
gofmt -s -w ./     #форматує код де використовує таб для відступів,пропусків,вирівнювання

#завантажемо пакети та залежності
go get

#білдуємо программу з новою версією
go build -ldflags "-X="github.com/Dennyyyyyyy/kbot/cmd.appVersion=1.0.2

#додамо токен в зміну TELE_TOKEN без збереження інформації в логах
read -s -w TOKEN_TELE #далі вставимо наш токен Ctrl+V

#єкспортуеємо зміну
export TELE_TOKEN

#запустимо програму та перевіримо
./kbot start

Чудово, все працює!

Комміт та пуш.
