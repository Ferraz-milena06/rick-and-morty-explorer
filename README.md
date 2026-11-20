# Rick & Morty Explorer — Flutter

Projeto acadêmico de catálogo interativo. API pública: https://rickandmortyapi.com/documentation

## Requisitos
- Flutter SDK instalado e configurado no PATH
- Android Studio ou IntelliJ IDEA com plugins Flutter e Dart
- Emulador Android ou celular com depuração USB

## Executar
1. Extraia o ZIP.
2. Abra a pasta `rick_morty_explorer` no IntelliJ IDEA.
3. Abra o terminal integrado na raiz do projeto.
4. Execute:
   ```bash
   flutter doctor
   flutter pub get
   flutter run
   ```
5. Selecione um emulador/celular quando solicitado.

## Primeiro acesso
Na tela inicial, digite qualquer usuário e senha e toque em **ENTRAR / CADASTRAR**. O primeiro acesso cria uma conta local no aparelho. Para entrar novamente, use os mesmos dados.

## Estrutura
- `lib/models`: modelo de personagem
- `lib/services`: comunicação HTTP com a API
- `lib/providers`: estado global, sessão, favoritos e lista de conhecidos
- `lib/screens`: login, catálogo, detalhes, favoritos e conhecidos

## Requisitos atendidos
RF01 catálogo em GridView e paginação; RF02 Navigator; RF03 detalhes via segunda requisição; RF04/RF05 Provider; RF06 SharedPreferences; RF07 login local e lista de conhecidos; RF08 busca; RF09 loading e erros; RF10 Semantics, labels, placeholders e interface responsiva.

## Observações acadêmicas
- O login é local e demonstrativo, conforme baseline do enunciado; não é autenticação segura para produção.
- “Personagens conhecidos” representa a adaptação de itens consumidos para o tema Rick and Morty.
- O projeto precisa ser executado e testado no seu ambiente antes da gravação do vídeo e da entrega.
