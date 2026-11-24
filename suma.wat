(module
  (func $suma (export "suma") (param $a i32) (param $b i32) (result i32)
    local.get $a
    local.get $b
    i32.add)
)