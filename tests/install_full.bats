load helpers

@test "install full: no decomposer.json" {
  run_decomposer install
  [ "${status}" -eq 1 ]
  [ "${lines[0]}" = "decomposer: No decomposer.json found." ]
  [ "${lines[1]}" = "Try 'decomposer help' for more information." ]
}

@test "install full: single new lib" {
  local decomposer_json=$(
cat << EOF
{
    "Library_1": {
        "url": "${TEST_REPOS_DIR}/lib1",
        "revision": "master",
        "version": "1.0",
        "psr4": {
            "prefix": "lib1",
            "search-path": "/src/Lib1/"
         }
     }
}
EOF
)
  create_decomposer_json "${decomposer_json}"

  create_repository lib1
  local lib1_revision_hash="${REVISION_HASH}"

  run_decomposer install
  [ "${status}" -eq 0 ]

  assert_lib_folder Library_1-1.0 commit "${lib1_revision_hash}"

  local expected_lib1_file=$(
cat << EOF
<?php

autoload_register_psr4_prefix('lib1', 'Library_1-1.0/src/Lib1/');

?>
EOF
)
  assert_lib_file Library_1-1.0 "${expected_lib1_file}"

  local expected_autoload_file=$(
cat << EOF
<?php

require_once 'Library_1-1.0.php';

?>
EOF
)
  assert_autoload_file "${expected_autoload_file}"
}