# Практикум: Git как в команде

Все команды выполняются в папке клонированного репозитория. Для PowerShell скриптов используйте
`powershell -NoProfile -ExecutionPolicy Bypass -File ...`: Bypass действует только для этого запуска,
постоянная политика компьютера не меняется. Нужны Git и .NET SDK 8.x.

## 1. Клонирование и обзор

В Visual Studio: Continue without code -> Git -> Clone Repository.
Адрес: `https://github.com/kingoffier/shoplite-lab.git`.
Выберите новую папку для рабочего клона. Через терминал:

```powershell
git clone https://github.com/kingoffier/shoplite-lab.git
cd shoplite-lab
```

Если используете исходный офлайн-пакет, вместо HTTPS можно клонировать путь к shoplite.git из НАЧНИ-ЗДЕСЬ.md.
При клонировании GitHub-адреса origin указывает на GitHub, и последующие Push отправляют ветки в GitHub.
Откройте ShopLite.sln. View -> Git Repository показывает граф, View -> Git Changes — правки.

```powershell
git status
git branch -a
git log --all --graph --decorate --oneline
git tag -n
dotnet run --project src/ShopLite
dotnet run --project tests/ShopLite.Checks
```
Это обычный clone с origin. `git init` здесь не нужен. Q закрывает просмотр длинного лога.
Настройте свои user.name и user.email, если ещё не настроены.

## 2. Новая функция и первые коммиты

Сценарий: добавить текстовую подпись к чеку. В VS: checkout develop, Pull, Git -> New Branch.

```powershell
git switch -c develop --track origin/develop
git pull --ff-only
git switch -c feature/my-receipt-footer
```
Если локальная develop уже существует, используйте `git switch develop`.
В конец Program.cs ПЕРЕД `return 0;` добавьте:
`Console.WriteLine("Спасибо за заказ! Поддержка: support@example.test");`
В VS: двойной щелчок по файлу в Git Changes -> проверить diff -> + -> Commit Staged.

```powershell
git diff
git add src/ShopLite/Program.cs
git commit -m "feat: add support contact to receipt"
```
Добавьте docs/support.md с инструкцией обращения в поддержку и создайте второй коммит.

```powershell
git add docs/support.md
git commit -m "docs: explain how to contact support"
dotnet run --project tests/ShopLite.Checks
git push -u origin feature/my-receipt-footer
```
Push отправляет ветку в origin: на GitHub при клонировании HTTPS-адреса или на локальный сервер при работе с офлайн-пакетом.
Для командного review сравните ветки: `git diff origin/develop...HEAD`.
В VS можно Compare branches. Для настоящего PR откройте GitHub -> Pull requests -> New pull request: base develop, compare feature/my-receipt-footer. После ревью можно выполнить Merge в GitHub вместо локального слияния в следующем разделе.

## 3. Объединение функции

В VS: checkout develop, правой кнопкой по feature/my-receipt-footer -> Merge into develop.
В реальной команде этот шаг обычно выполняет PR после ревью и CI. Если PR уже объединён на GitHub, достаточно переключиться на develop и выполнить git pull --ff-only; повторный локальный merge не нужен.

```powershell
git switch develop
git pull --ff-only
git merge --no-ff feature/my-receipt-footer -m "merge: receipt footer after local review"
dotnet run --project tests/ShopLite.Checks
git push
```
Вы объединили работу в develop; main и production ещё не поменялись.

## 4. Настоящий конфликт в коде

Коллега уже подготовил origin/feature/lower-delivery-threshold (2500 RUB).
Ваша задача на своей ветке — 3500 RUB. Обе ветки меняют одну строку одного файла.

```powershell
git switch develop
git switch -c feature/my-delivery-threshold
```
В src/ShopLite/DeliveryPolicy.cs замените 3000m на 3500m.
В docs/shipping.md замените 3000 на 3500.
В тестах замените тест exact threshold на Calculate(3500m) == 3500m,
а just below threshold на Calculate(3499.99m) == 3799.99m.

```powershell
git add src/ShopLite/DeliveryPolicy.cs docs/shipping.md tests/ShopLite.Checks/Program.cs
git commit -m "feat: raise free shipping threshold to 3500 RUB"
git fetch origin
git merge origin/feature/lower-delivery-threshold
```
Git остановится на конфликте. Это ожидаемо.
В VS: Git Changes -> Unmerged Changes -> двойной щелчок -> Merge Editor.
В Result согласуйте значение 3500m, сохраните и Accept Merge.
Исправьте конфликтующий текст docs/shipping.md на 3500.
В конфликтующих тестах оставьте проверки для 3500 и 3499.99 из своей ветки.
Удалите все маркеры конфликта во всех трёх файлах.

```powershell
git add src/ShopLite/DeliveryPolicy.cs docs/shipping.md tests/ShopLite.Checks/Program.cs
git commit --no-edit
dotnet run --project tests/ShopLite.Checks
git push -u origin feature/my-delivery-threshold
```
Пока не сливайте эту ветку в develop: для первого релиза используем уже готовую подпись чека.
Отменить незавершённый merge можно командой `git merge --abort`.

## 5. Релиз v1.4.0

```powershell
git switch develop
git pull --ff-only
git switch -c release/my-1.4.0
```
Добавьте запись о подписи чека в CHANGELOG.md, затем:

```powershell
git add CHANGELOG.md
git commit -m "release: prepare v1.4.0"
dotnet run --project tests/ShopLite.Checks
git switch main
git pull --ff-only
git merge --no-ff release/my-1.4.0 -m "merge: release v1.4.0"
git tag -a v1.4.0 -m "Release 1.4.0: receipt footer"
git push origin main
git push origin v1.4.0
git switch develop
git merge main
git push origin develop
```
Релизный тег указывает на точный коммит. Создание тега и Push сами по себе ничего локально не деплоят.

## 6. Сборка и деплой своими руками

В VS откройте View -> Terminal. Команды одинаковые:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Build-Artifact.ps1 -Ref v1.4.0
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Deploy.ps1 -Version v1.4.0 -Environment staging
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Run-Current.ps1 -Environment staging
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Deploy.ps1 -Version v1.4.0 -Environment production
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Run-Current.ps1 -Environment production
```
Build берёт исходники из тега, запускает проверки, публикует DLL и сохраняет SHA256.
Deploy проверяет хеши и smoke, затем меняет current.json. Оба окружения используют ОДИН артефакт.
Сборка и переключение окружения — разные операции. `.lab/` игнорируется Git.

```powershell
Get-Content .lab/environments/deployments.jsonl
Get-Content .lab/environments/production/current.json
```

## 7. Повторить инцидент и rollback

Используйте изолированные каталоги .lab/replay — они не затронут вашу v1.4.0.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Build-Artifact.ps1 -Ref v1.2.1 -ArtifactRoot .lab/replay/artifacts
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Build-Artifact.ps1 -Ref v1.3.0 -ArtifactRoot .lab/replay/artifacts
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Deploy.ps1 -Version v1.2.1 -Environment production -ArtifactRoot .lab/replay/artifacts -EnvironmentRoot .lab/replay/environments
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Deploy.ps1 -Version v1.3.0 -Environment production -ArtifactRoot .lab/replay/artifacts -EnvironmentRoot .lab/replay/environments
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Run-Current.ps1 -Environment production -ProbeLoyalty -ArtifactRoot .lab/replay/artifacts -EnvironmentRoot .lab/replay/environments
```
Последняя команда НАМЕРЕННО завершится кодом 2: VIP expected=9000, actual=8000.
Это учебный дефект v1.3.0, а не поломка стенда. Basic smoke его не обнаруживает.
Возврат предыдущего готового артефакта:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Deploy.ps1 -Version v1.2.1 -Environment production -Rollback -ArtifactRoot .lab/replay/artifacts -EnvironmentRoot .lab/replay/environments
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Run-Current.ps1 -Environment production -ArtifactRoot .lab/replay/artifacts -EnvironmentRoot .lab/replay/environments
```
Rollback не делает git reset, не меняет main и не удаляет коммиты.
Вы возвращаете production на предыдущий пакет, пока исправляется ошибка.
Разбор: docs/incidents/INC-001.md; исправление: hotfix/vip-discount и тег v1.3.1.

## 8. Опубликованный коммит, который нужно отменить

Создайте безопасную тренировочную ветку, добавьте docs/experiment.md и закоммитьте её.

```powershell
git switch develop
git switch -c experiment/revert
```
После создания файла:

```powershell
git add docs/experiment.md
git commit -m "experiment: add temporary note"
git push -u origin experiment/revert
git revert --no-edit HEAD
git push
git log --oneline -3
```
Будут два коммита: исходная правка и её отмена. История сохранится.

## 9. GitHub и собственная копия

Репозиторий уже опубликован: https://github.com/kingoffier/shoplite-lab.
Если вы клонировали его HTTPS-адрес, origin уже настроен: дополнительный remote github не нужен.
Ваши новые ветки после Push появятся в Branches, PR создаются в Pull requests,
сборки видны в Actions. История выполненных локальных деплоев: [history/DEPLOYMENTS.md](history/DEPLOYMENTS.md).
Автоматического облачного CD в этом проекте нет.

Следующие команды относятся только к переносу офлайн-пакета в ДРУГОЙ новый репозиторий.

Создайте на GitHub пустой репозиторий без README, лицензии и .gitignore.
Из своего рабочего клона добавьте второй remote; origin сохранится локальным учебным сервером:

```powershell
git remote add github https://github.com/YOUR_LOGIN/shoplite-lab.git
git push github main
git push github develop
git push github --tags
git push github feature/my-receipt-footer
```
Для копирования остальных учебных веток используйте инструкции НАЧНИ-ЗДЕСЬ.md и bundle.
Новый PR feature/my-receipt-footer -> develop будет пустым, если вы уже выполнили локальное слияние.
Создайте НОВУЮ ветку от develop с новой правкой, отправьте её на github и откройте PR.
CI workflow начнёт запускаться только на GitHub; прошлые Actions runs этим не создаются.
Права, защита веток, ревью и окружения GitHub настраиваются отдельно.
Локальный CD не является деплоем на GitHub Pages или облачный сервер.

## Что здесь стоит запомнить

Commit сохраняет историю; push передаёт её серверу; PR организует ревью;
merge объединяет код; tag фиксирует версию; build создаёт артефакт;
deploy выбирает артефакт для окружения; rollback возвращает предыдущий артефакт.
Эти действия связаны, но не заменяют друг друга.
