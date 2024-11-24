#!/bin/bash

# Get a list of outdated formulae
outdated_formulae=($(brew outdated | awk '{print $1}'))

# Iterate over the list and uninstall each outdated formula
for formula in "${outdated_formulae[@]}"
do
    brew uninstall "$formula"
done