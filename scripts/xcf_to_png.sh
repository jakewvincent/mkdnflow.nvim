# xcf_to_png.sh
#!/bin/bash

# Find XCF files that have been modified more recently than their corresponding PNG files
xcf_files_to_convert=$(find . -name '*.xcf' | while read xcf_file; do
    png_file="${xcf_file%.xcf}.png"
    if [ ! -f "$png_file" ] || [ "$xcf_file" -nt "$png_file" ]; then
        echo "$xcf_file"
    fi
done)

# Convert the XCF files to PNG
for file in $xcf_files_to_convert; do
    if [ -f "$file" ]; then
        dir_name=$(dirname "$file")
        base_name=$(basename "$file" .xcf)
        output_file="$dir_name/$base_name.png"
        gimp -i -b "
            (let* (
                    (image (car (gimp-file-load RUN-NONINTERACTIVE \"$file\" \"$file\")))
                    (merged-layer (car (gimp-image-merge-visible-layers image CLIP-TO-BOTTOM-LAYER)))
                )
                (file-png-save RUN-NONINTERACTIVE image merged-layer \"$output_file\" \"$output_file\" 0 9 0 0 0 0 0)
                (gimp-image-delete image)
            )
            (gimp-quit 0)
        "
        echo "  Converted $file to $base_name.png"
    fi
done

