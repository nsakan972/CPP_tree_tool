#!/bin/bash

# Функција за креирање директоријума ако не постоји
create_dir() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        echo "Директоријум креиран: $1"
    fi
}

# Функција за креирање .hpp фајла са основним подешавањима
create_hpp() {
    local filename="$1"
    local base=$(basename "$filename")
    local ns=$(basename "$(dirname "$filename")")
    local guard_name=$(echo "$base" | tr '[:lower:]' '[:upper:]' | sed 's/[^A-Z0-9]/_/g')
    
    cat > "$filename.hpp" << EOF
#ifndef __${guard_name}_HPP__
#define __${guard_name}_HPP__

#include <iostream>
#include <fstream>
#include <vector>
$( if [ "$ns" != "main" ]; then
    echo
    echo "namespace $ns {"
    if [ "$base" != "$ns" ]; then
        echo
        echo "class $base {"
        echo "public:"
        echo "  $base();"
        echo "  ~$base();"
        echo
        echo "private:"
        echo
        echo "};"
    else
        echo
    fi
    echo
    echo "} // namespace $ns"
fi )
#endif // __${guard_name}_HPP__
EOF
    echo "Креиран фајл: $filename.hpp"
}

# Функција за креирање .cpp фајла
create_cpp() {
    local filename="$1"
    local base="$(basename "$filename")"
    local ns=$(basename "$(dirname "$filename")")

    cat > "$filename.cpp" << EOF
#include "$base.hpp"
$( if [ "$ns" != "main" ]; then
    echo
    echo "namespace $ns {"
    if [ "$base" != "$ns" ]; then
        echo
        echo "$base::$base() {"
        echo "}"
        echo
        echo "$base::~$base() {"
        echo "}"
    else
        echo
    fi
    echo
    echo "} // namespace $ns"
else
    echo ""
    echo "int main(int argc, char *argv[]) {"
    echo "  std::cout << \"Hello, World!\" << \"\n\";"
    echo "    return 0;"
    echo "}"
fi )
EOF
    echo "Креиран фајл: $filename.cpp"
}

# Помоћна функција: Додај #include "<name>.hpp" у .hpp после последњег #include
add_include_to_header() {
    local header_path="$1"
    local include_base="$2"

    # Не додај ако већ постоји
    if grep -qF "#include \"${include_base}.hpp\"" "$header_path"; then
        echo "Include већ постоји у: $header_path"
        return 0
    fi

    # Пронађи линију последњег include-а; ако не постоји, постави на 2 (након #define)
    local last
    last=$(grep -n '^#include ' "$header_path" | tail -n1 | cut -d: -f1)
    if [ -z "$last" ]; then
        last=2
    fi

    awk -v pos="$last" -v base="$include_base" '
        {
            print
            if (NR == pos) {
                print "#include \"" base ".hpp\""
            }
        }
    ' "$header_path" > "${header_path}.tmp" && mv "${header_path}.tmp" "$header_path"
}

# Главна логика скрипта
if [ $# -eq 0 ]; then
    echo "Употреба:"
    echo "  ./stvori_cpp_stablo.sh namespace"
    echo "  ./stvori_cpp_stablo.sh namespace class"
    exit 1
fi

# Креирање src директоријума ако не постоји
create_dir "src"

# Логика креирања на основу аргумената
if [ $# -eq 1 ]; then
    ns="$1"
    dir="src/$ns"
    create_dir "$dir"
    create_hpp "$dir/$ns"
    create_cpp "$dir/$ns"
elif [ $# -eq 2 ]; then
    ns="$1"
    cls="$2"
    dir="src/$ns"
    create_dir "$dir"

    ns_base="$dir/$ns"
    cls_base="$dir/$cls"

    # Осигурај да namespace базни фајлови постоје
    if [ ! -f "${ns_base}.hpp" ]; then
        create_hpp "$ns_base"
    fi
    if [ ! -f "${ns_base}.cpp" ]; then
        create_cpp "$ns_base"
    fi

    # Креирај class фајлове ако не постоје
    if [ ! -f "${cls_base}.hpp" ]; then
        create_hpp "$cls_base"
    else
        echo "Већ постоји: ${cls_base}.hpp"
    fi
    if [ ! -f "${cls_base}.cpp" ]; then
        create_cpp "$cls_base"
    else
        echo "Већ постоји: ${cls_base}.cpp"
    fi

    # Додај include у namespace.hpp
    add_include_to_header "${ns_base}.hpp" "$cls"

    # Освежи main.hpp да укључи namespace.hpp
    main_dir="src/main"
    main_base="${main_dir}/main"
    if [ -f "${main_base}.hpp" ] && [ -f "${main_base}.cpp" ]; then
        add_include_to_header "${main_base}.hpp" "../$ns/$ns"
    else
        create_dir "$main_dir"
        # Креирај main пар ако не постоји
        if [ ! -f "${main_base}.hpp" ]; then
            create_hpp "${main_base}"
        fi
        if [ ! -f "${main_base}.cpp" ]; then
            create_cpp "${main_base}"
        fi
        # Додај include namespace.hpp у main.hpp
        add_include_to_header "${main_base}.hpp" "../$ns/$ns"
    fi
else
    echo "Неисправна команда"
    echo "Употреба:"
    echo "  ./stvori_cpp_stablo.sh namespace"
    echo "  ./stvori_cpp_stablo.sh namespace class"
    exit 1
fi
