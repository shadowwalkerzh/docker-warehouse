#!/usr/bin/env bash

# Enable (set) each optname. 
# If globstar set, the pattern ** used in a path name expansion context will match 
# all files and zero or more directories and subdirectories. 
# If the pattern is followed by a /, only directories and subdirectories match.
shopt -s globstar

pull_image() {
	local pull_url image_dir
	pull_url="$1"
	dir="$2"
	curl -fSsL "$pull_url" > "$dir/images.tar.gz"
}

build_image() {
	declare options_files="${*:-/**/options}"

	for file in $options_files; do
		( # shellcheck source=/python3.7-shanghai-base/options
		source "$file"
		local =
		image_dir="${file%/*}"

		[[ "$PULL_URL" ]] && pull_image "$PULL_URL" "$image_dir"
		[[ "$BUILD_OPTIONS" ]] && build_image "${BUILD_OPTIONS[@]}" "$image_dir"

		# Build + tag images
		for tag in "${TAGS[@]}"; do
			docker build -t "$tag" "$image_dir"

			if [[ "$CIRCLE_BUILD_NUM" ]]; then
				{
					mkdir -p images \
					&& docker tag "$tag" "${tag}-${CIRCLE_BUILD_NUM}" \
					&& docker save "${tag}-${CIRCLE_BUILD_NUM}" \
						| xz -9e > "images/${tag//\//_}-${CIRCLE_BUILD_NUM}.tar.xz" \
					&& docker rmi "${tag}-${CIRCLE_BUILD_NUM}"
				} || true
			fi
		done )

	done
}

push_image() {
	[[ "$CIRCLE_BRANCH" == "release" ]] || return 0
	[[ "$NO_PUSH" ]] && return 0
	declare options_files="${*:-/**/options}"
	for file in $options_files; do
		( #shellcheck source=/python3.7-shanghai-base/options
		source "$file"
		for tag in "${TAGS[@]}"; do
			if docker history "$tag" &> /dev/null; then
				[[ "$PUSH_IMAGE" ]] && docker push "$tag"
			fi
		done
		exit 0 )
	done
}

run_image() {
	local build_options build_dir
	build_options="$1"
	build_dir="$2"
	docker run -e "TRACE=$TRACE" --rm "$BUILD_IMAGE" "${BUILD_OPTIONS[@]}" > "$image_dir/images.tar.xz"
}

main() {
	set -eo pipefail; [[ "$TRACE" ]] && set -x
	declare cmd="$1"
	case "$cmd" in
		push)	shift;	push_image "$@";;
		*)		build_image "$@";;
	esac
}

main "$@"
