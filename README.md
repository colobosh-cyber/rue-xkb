# Rusyn (RUE) Keyboard Layout for Linux (XKB) and Windows

Rusyn keyboard layout (RUE) for Linux (XKB) and Windows. Carpathian phonetic layout with AltGr support.

![Release](https://img.shields.io/github/v/release/colobosh-cyber/rue-xkb)
![Downloads](https://img.shields.io/github/downloads/colobosh-cyber/rue-xkb/total)
![License](https://img.shields.io/github/license/colobosh-cyber/rue-xkb)

## Download

👉 https://github.com/colobosh-cyber/rue-xkb/releases

Choose your platform: Linux (.deb) or Windows (.exe)

## Keyboard Layout

<p align="center">
  <img src="assets/keyboard.png" alt="RUE Keyboard Layout" width="900"/>
</p>

## Особливості

* Фонетична розкладка на базі `ua(phonetic)`
* Повна підтримка русинських літер:

  * **ґ / Ґ**
  * **ы**
  * **ӱ**
* Розширені символи через **AltGr**:

  * № © × ÷ € „ “ —
* Узгоджена логіка з Windows-версією (.klc)

---

## Встановлення

```bash
git clone https://github.com/YOUR_USERNAME/rue-xkb.git
cd rue-xkb
chmod +x install.sh
sudo ./install.sh
```

---

## Активація розкладки

Після встановлення:

1. Відкрий **Settings → Keyboard → Input Sources**
2. Додай:

   ```
   Rusyn (Carpathian phonetic)
   ```
3. Формат:

   ```
   ('xkb', 'rue+rusyn')
   ```

---

## Важливо: AltGr (3-й рівень)

Якщо AltGr не працює, виконай команду
`gsettings set org.gnome.desktop.input-sources xkb-options "['lv3:ralt_switch']"`

---

## Застосування змін

Після встановлення або видалення розкладки виконай:

`sudo dpkg-reconfigure xkb-data`

Однак цього може бути недостатньо.

Якщо розкладка не з’явилася або не почала працювати одразу:

- вийди з сеансу і зайди знову, або
- перезавантаж ПК

Найнадійніший спосіб застосувати зміни — перезавантаження системи.

---

## Видалення

Запусти:

`chmod +x uninstall.sh`
`sudo ./uninstall.sh`

---

## Після видалення (важливо)

Після видалення розкладки в GNOME може залишатися неробочий запис "Rusyn".

Це нормальна поведінка, тому що GNOME зберігає список джерел вводу у власних налаштуваннях користувача, а не в системі XKB.

### Як прибрати

Відкрий:

**Settings → Keyboard → Input Sources**

і видали:

**Rusyn (Carpathian phonetic)**

### Або через термінал

Перевір поточні джерела вводу:

`gsettings get org.gnome.desktop.input-sources sources`

Знайди і видали запис:

`('xkb', 'rue+rusyn')`

Після цього задай оновлений список, наприклад:

`gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'ua')]"`

---

## Сумісність

Перевірено на:

* Ubuntu 24.04
* Ubuntu 26.04 (development)

Очікується робота на:

* Debian
* Linux Mint
* інші Debian-based системи

---

## Примітки

* Працює під Wayland і X11
* Може вимагати повторного додавання розкладки

---

## Ліцензія

MIT License

## Keywords

rusyn keyboard linux, rue layout, rusyn keyboard ubuntu, xkb rusyn, carpathian keyboard layout, rusyn windows keyboard

