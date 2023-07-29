#!/usr/bin/env bash

function copyFile {
	local SOURCE_FILE="$1/$2"
	local TARGET_FILE="$2"

	if test -f "$SOURCE_FILE"; then
		echo "Creating directory and copying for target file '$TARGET_FILE'"
		mkdir -p $(dirname $TARGET_FILE)
		cp $SOURCE_FILE $TARGET_FILE
	else
		echo "Skip copying file; source file '$SOURCE_FILE' does not exist"
	fi
}

function copyMissingFile {
	local SOURCE_DIR="$1"
	local TARGET_FILE="$2"

	if test -f "$TARGET_FILE"; then
		echo "Skip copying file; target file '$TARGET_FILE' exists"
	else
		copyFile $SOURCE_DIR $TARGET_FILE
	fi
}

function updateLabels {
	if [ "$XARGS_DRY_RUN" == "true" ]; then
		echo "Skip updating labels; --dry-run mode"
	else
		echo "Updating labels from $XARGS_REPO_OWNER/$XARGS_REPO_NAME"
		gh label clone "$XARGS_REPO_OWNER/$XARGS_REPO_NAME"
	fi
}
