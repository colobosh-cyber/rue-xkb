#!/usr/bin/env bash
set -euo pipefail

XKB_DIR="/usr/share/X11/xkb"
RULES_DIR="$XKB_DIR/rules"

SRC_SYMBOLS="symbols/rue"
DST_SYMBOLS="$XKB_DIR/symbols/rue"

EVDEV_LST="$RULES_DIR/evdev.lst"
EVDEV_XML="$RULES_DIR/evdev.xml"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

RUE_LAYOUT_LINE="rue             Rusyn"
RUSYN_VARIANT_LINE="  rusyn         rue: Rusyn (Carpathian phonetic)"

require_root() {
    if [[ "$EUID" -ne 0 ]]; then
        echo "Помилка: запусти скрипт через sudo."
        exit 1
    fi
}

check_inputs() {
    [[ -f "$SRC_SYMBOLS" ]] || { echo "Не знайдено файл: $SRC_SYMBOLS"; exit 1; }
    [[ -f "$EVDEV_LST" ]] || { echo "Не знайдено файл: $EVDEV_LST"; exit 1; }
    [[ -f "$EVDEV_XML" ]] || { echo "Не знайдено файл: $EVDEV_XML"; exit 1; }
}

backup_file() {
    local file="$1"
    local backup="${file}.bak-rue-$(date +%Y%m%d-%H%M%S)"
    cp -a "$file" "$backup"
    echo "Backup: $backup"
}

install_symbols_file() {
    echo "Копіюю symbols/rue ..."
    install -m 0644 "$SRC_SYMBOLS" "$DST_SYMBOLS"
}

patch_evdev_lst() {
    echo "Оновлюю evdev.lst ..."

    local has_layout=0
    local has_variant=0

    grep -Fq "$RUE_LAYOUT_LINE" "$EVDEV_LST" && has_layout=1
    grep -Fq "$RUSYN_VARIANT_LINE" "$EVDEV_LST" && has_variant=1

    if [[ "$has_layout" -eq 1 && "$has_variant" -eq 1 ]]; then
        echo "Rue/Rusyn уже є в evdev.lst"
        return
    fi

    if [[ "$has_layout" -eq 1 ]]; then
        awk -v variant="$RUSYN_VARIANT_LINE" '
        BEGIN { inserted=0 }
        {
            print
            if ($0 == "rue             Rusyn" && inserted==0) {
                print variant
                inserted=1
            }
        }
        END {
            if (inserted==0) exit 2
        }' "$EVDEV_LST" > "$TMP_DIR/evdev.lst.new" || {
            echo "Не вдалося дописати variant rusyn у evdev.lst"
            return 1
        }
    else
        cp "$EVDEV_LST" "$TMP_DIR/evdev.lst.new"
        printf "\n%s\n%s\n" "$RUE_LAYOUT_LINE" "$RUSYN_VARIANT_LINE" >> "$TMP_DIR/evdev.lst.new"
    fi

    cp "$TMP_DIR/evdev.lst.new" "$EVDEV_LST"
    echo "evdev.lst оновлено."
}

patch_evdev_xml() {
    echo "Оновлюю evdev.xml ..."

    local has_rue_layout=0

    awk '
    /<layout>/ {
        block=$0 "\n"
        inblock=1
        next
    }
    inblock {
        block = block $0 "\n"
        if ($0 ~ /<\/layout>/) {
            if (block ~ /<layout>[[:space:][:cntrl:]]*<configItem>[[:space:][:cntrl:]]*<name>rue<\/name>/) {
                found=1
            }
            block=""
            inblock=0
        }
        next
    }
    END {
        if (found) exit 0
        else exit 1
    }' "$EVDEV_XML" && has_rue_layout=1 || true

    if [[ "$has_rue_layout" -eq 1 ]]; then
        echo "Окремий layout rue уже є в evdev.xml"
        return
    fi

    cat > "$TMP_DIR/rue-layout.xml" <<'EOF'
    <layout>
      <!-- Keyboard indicator for Rusyn layouts -->
      <configItem>
        <name>rue</name>
        <shortDescription>rue</shortDescription>
        <description>Rusyn</description>
        <languageList>
          <iso639Id>rue</iso639Id>
        </languageList>
      </configItem>
      <variantList>
        <variant>
          <configItem>
            <name>rusyn</name>
            <description>Rusyn (Carpathian phonetic)</description>
          </configItem>
        </variant>
      </variantList>
    </layout>
EOF

    awk '
    BEGIN { inserted=0 }
    /<\/layoutList>/ && inserted==0 {
        while ((getline line < "'"$TMP_DIR"'/rue-layout.xml") > 0) {
            print line
        }
        close("'"$TMP_DIR"'/rue-layout.xml")
        inserted=1
    }
    { print }
    END {
        if (inserted==0) exit 2
    }' "$EVDEV_XML" > "$TMP_DIR/evdev.xml.new" || {
        echo "Не вдалося вставити layout rue у evdev.xml"
        echo "evdev.xml не змінено."
        return 1
    }

    cp "$TMP_DIR/evdev.xml.new" "$EVDEV_XML"
    echo "evdev.xml оновлено."
}

reconfigure_xkb() {
    echo "Оновлюю XKB через dpkg-reconfigure xkb-data ..."
    dpkg-reconfigure xkb-data >/dev/null 2>&1 || true
}

show_final_notes() {
    echo
    echo "Готово."
    echo
    echo "Що далі:"
    echo "1. Додай розкладку Rue/Rusyn у GNOME Settings."
    echo "2. Якщо зміни не підхопились одразу, виконай:"
    echo "   sudo dpkg-reconfigure xkb-data"
    echo "3. Якщо AltGr не працює, виконай:"
    echo "   gsettings set org.gnome.desktop.input-sources xkb-options \"['lv3:ralt_switch']\""
    echo
    echo "Очікуваний формат джерела вводу:"
    echo "   ('xkb', 'rue+rusyn')"
}

main() {
    require_root
    check_inputs

    backup_file "$EVDEV_LST"
    backup_file "$EVDEV_XML"

    install_symbols_file
    patch_evdev_lst
    patch_evdev_xml
    reconfigure_xkb
    show_final_notes
}

main "$@"
