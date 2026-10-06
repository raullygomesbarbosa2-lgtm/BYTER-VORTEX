# Byte Vortex AI

Catálogo web público. Visitantes podem navegar e baixar arquivos publicados; usuários que entrarem podem ter conta, mas somente o proprietário registrado em `site_admins` pode enviar, atualizar ou remover itens. A permissão é aplicada por políticas RLS no Supabase, não apenas pela interface.

## Serviços

- GitHub Pages: hospeda a interface pública.
- Supabase: login por link de e-mail, banco do catálogo, armazenamento e regras de acesso.

## Configuração do Supabase

1. Crie ou escolha um projeto Supabase.
2. No SQL Editor, execute `supabase-setup.sql`.
3. No Authentication > URL Configuration, defina o endereço público do site como Site URL e adicione também a URL pública à lista de Redirect URLs.
4. Em Project Settings > API, copie a Project URL e a chave pública `anon`/`publishable` para as duas constantes do `index.html`.
5. Publique o site e entre uma vez usando o e-mail do proprietário.
6. No SQL Editor, execute o bloco abaixo substituindo o marcador pelo e-mail da conta proprietária:

```sql
insert into public.site_admins(user_id)
select id from auth.users
where lower(email) = lower('COLE_AQUI_O_EMAIL_DO_PROPRIETARIO')
on conflict (user_id) do nothing;
```

A chave `service_role` e a senha do banco nunca devem ser colocadas no HTML, no GitHub ou em mensagens.

## Publicação

O repositório pode ser servido pelo GitHub Pages a partir da branch `main`, pasta raiz (`/`). Depois de habilitar Pages, ajuste a Site URL e Redirect URLs do Supabase para o endereço exato informado pelo GitHub.

## Conteúdo

Publique apenas emuladores, homebrew, arquivos de domínio público ou outros materiais que o proprietário tenha autorização para distribuir. O site não deve ser usado para disponibilizar cópias não autorizadas de jogos, ROMs ou BIOS.
