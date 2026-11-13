# Portcullis

Linguagem de programação experimental implementada em Zig 0.15.2.

```sh
zig build
zig build test
zig build run -- "50 - 10 + 2"
```

O último comando imprime `42`. O executável fica em `zig-out/bin`.

O interpretador aceita literais decimais de 0 a 2⁶³ − 1, espaços em branco e os operadores binários `+` e `-`. Os operadores têm a mesma precedência e são avaliados da esquerda para a direita. O resultado é um inteiro de 64 bits com sinal, com erro em caso de estouro.

`src/main.zig` implementa a interface de linha de comando. `src/language.zig` contém o analisador léxico, o avaliador e os testes da linguagem.
