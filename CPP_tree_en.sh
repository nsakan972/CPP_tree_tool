#!/bin/bash

# Function: create directory if it does not exist
create_dir() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        echo "Directory created successfully: $1"
    fi
}

# Function: create a .hpp file with basic boilerplate
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
    echo "Created file: $filename.hpp"
}

# Function: create a .cpp file
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
    echo "Created file: $filename.cpp"
}

# Helper: append #include "<name>.hpp" into a header after the last existing #include
add_include_to_header() {
    local header_path="$1"
    local include_base="$2"

    # Skip if the include already exists
    if grep -qF "#include \"${include_base}.hpp\"" "$header_path"; then
        echo "Include already present in: $header_path"
        return 0
    fi

    # Find the last include line; if none, insert after the #define line (line 2)
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

# Main script logic
if [ $# -eq 0 ]; then
    echo "Usage:"
    echo "  ./CPP_tree_en.sh namespace"
    echo "  ./CPP_tree_en.sh namespace class"
    exit 1
fi

# Ensure src directory exists
create_dir "src"

# Argument-driven generation logic
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

    # Ensure base namespace files exist
    if [ ! -f "${ns_base}.hpp" ]; then
        create_hpp "$ns_base"
    fi
    if [ ! -f "${ns_base}.cpp" ]; then
        create_cpp "$ns_base"
    fi

    # Create class files if missing
    if [ ! -f "${cls_base}.hpp" ]; then
        create_hpp "$cls_base"
    else
        echo "File already exists: ${cls_base}.hpp"
    fi
    if [ ! -f "${cls_base}.cpp" ]; then
        create_cpp "$cls_base"
    else
        echo "File already exists: ${cls_base}.cpp"
    fi

    # Add include into namespace.hpp
    add_include_to_header "${ns_base}.hpp" "$cls"

    # Update main.hpp to include namespace.hpp
    main_dir="src/main"
    main_base="${main_dir}/main"
    if [ -f "${main_base}.hpp" ] && [ -f "${main_base}.cpp" ]; then
        add_include_to_header "${main_base}.hpp" "../$ns/$ns"
    else
        create_dir "$main_dir"
        # Create main pair if missing
        if [ ! -f "${main_base}.hpp" ]; then
            create_hpp "${main_base}"
        fi
        if [ ! -f "${main_base}.cpp" ]; then
            create_cpp "${main_base}"
        fi
        # Add include to main.hpp
        add_include_to_header "${main_base}.hpp" "../$ns/$ns"
    fi
else
    echo "Invalid command"
    echo "Usage:"
    echo "  ./CPP_tree_en.sh namespace"
    echo "  ./CPP_tree_en.sh namespace class"
    exit 1
fi
