# Portcullis

Linguagem de programação experimental implementada em Zig 0.15.2.

```sh
zig build
zig build test
zig build run -- "50 - 10 + 2"
```

O último comando imprime `42`. O executável fica em `zig-out/bin`.

O interpretador aceita literais decimais de 0 a 2⁶³ − 1, espaços em branco e os operadores binários `+` e `-`. Os operadores têm a mesma precedência e são avaliados da esquerda para a direita. O resultado é um inteiro de 64 bits com sinal, com erro em caso de estouro.

- `src/main.zig` implementa a interface de linha de comando.
- `src/lexer.zig` transforma o texto em tokens.
- `src/parser.zig` aplica a gramática e monta a expressão.
- `src/evaluator.zig` interpreta a expressão e contém os testes.
- `src/codegen.zig` traduz a expressão para C.

## Gerar um executável nativo

No PowerShell:

```powershell
zig build run -- emit-c "50 - 10 + 2" | Set-Content -Encoding ascii demo.c
zig cc -O2 demo.c -o demo.exe
.\demo.exe
```

O lexer reconhece inteiros e operadores. O parser aplica a regra
`expression = integer { ("+" | "-") integer }`, em que as chaves indicam
zero ou mais repetições. O gerador de C percorre a expressão analisada
e emite operações com verificação de estouro.
