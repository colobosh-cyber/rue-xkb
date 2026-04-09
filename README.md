# Rusyn RUE Keyboard Layout

Ubuntu / XKB layout (Carpathian phonetic)  
Linux + Windows support
Modern phonetic keyboard layout for Rusyn language across Linux and Windows.

![Release](https://img.shields.io/github/v/release/colobosh-cyber/rue-xkb)
![Downloads](https://img.shields.io/github/downloads/colobosh-cyber/rue-xkb/total)
![License](https://img.shields.io/github/license/colobosh-cyber/rue-xkb)

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
* Встановлення без перезавантаження системи

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

## Оновлення без перезавантаження

Щоб застосувати зміни XKB без перезавантаження системи, виконай:

```bash
sudo dpkg-reconfigure xkb-data


## Після видалення (важливо)

Після видалення розкладки в GNOME може залишатися неробочий запис "Rusyn".

Це нормальна поведінка, тому що GNOME зберігає список джерел вводу
у власних налаштуваннях користувача, а не в системі XKB.

### Як прибрати

Відкрий:

**Settings → Keyboard → Input Sources**

і видали:

**Rusyn (Carpathian phonetic)**

### Або через термінал

Перевір поточні джерела вводу:

```bash
gsettings get org.gnome.desktop.input-sources sources
```

Знайди і видали запис:

```text
('xkb', 'rue+rusyn')
```

Після цього задай оновлений список, наприклад:

```bash
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'ua')]"
```

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

* Не потребує перезавантаження
* Працює під Wayland і X11
* Може вимагати повторного додавання розкладки в GNOME після змін

---

## Ліцензія

MIT License

---

## Автор

RUE Rusyn layout (Carpathian / Lemko variant)

## Windows

Файли для Windows знаходяться в папці: windows/

### Встановлення

1. Відкрий папку `windows/installer`
2. Запусти `.exe`
3. Додай розкладку в налаштуваннях Windows

### Файли

* `.klc` — джерело розкладки
* `.exe` — готовий інсталятор
* PDF — схема клавіатури

---

