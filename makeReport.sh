#!/bin/bash


SRC_FILES=("src/top.vhd" "src/GameEngine.vhd" "src/GraphicsEngine.vhd")
TMP_FILE=".tmp.md"
OUT_FILE="GerberLamb_ECE5730_FinalProject.pdf"


cat > $TMP_FILE << EOF
---
title: Final Project
subtitle: ECE 5730
author: Andrew Gerber, Joseph Lamb
date: \today{}
geometry: margin=1in
documentclass: scrartcl
---

$(cat README.md)
EOF


ALPHABET=({A..Z})
ALPHABET_INDEX=0
for FILENAME in "${SRC_FILES[@]}"; do
    FILE_CONTENT=$(cat "$FILENAME")
    cat >> $TMP_FILE << EOF

\\pagebreak

# Appendix ${ALPHABET[ALPHABET_INDEX]}
**$FILENAME**
\`\`\`vhdl
$FILE_CONTENT
\`\`\`

EOF
    ((ALPHABET_INDEX++))
done


pandoc "$TMP_FILE" -o "$OUT_FILE"

rm "$TMP_FILE"

