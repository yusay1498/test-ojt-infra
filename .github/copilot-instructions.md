# Copilot Instructions

## 言語
- **必ず日本語で回答すること**
- コードレビューのコメントも日本語で記述すること
- 技術用語（API、endpoint、callback 等）は英語のままでよい

## Pull Request タイトル
- **必ず英語で記述すること**
- 先頭は大文字で始めること
- `feat:`, `fix:`, `docs:`, `chore:` などの conventional commit prefix を**使わないこと**
- 簡潔に変更内容を表す英語フレーズにすること

例：
- ✅ `Add user authentication feature`
- ✅ `Remove stale template artifacts`
- ❌ `feat: add user authentication`
- ❌ `chore: remove stale template artifacts`

## コミットメッセージ
- **必ず英語で記述すること**
- 先頭は大文字の英語で始めること
- `feat:`, `fix:`, `docs:`, `chore:` などの conventional commit prefix を**使わないこと**
- 1文で簡潔に変更を説明すること
- ピリオド・カンマ・接続詞は避けること
- 50文字以内に収めること

例：
- ✅ `Add null check in auth middleware`
- ✅ `Remove unused template files`
- ❌ `feat: add null check`
- ❌ `chore: remove unused files`

## Pull Request 説明文
- **必ず日本語で記述すること**
- リポジトリの `pull_request_template.md` のフォーマットに従うこと
- 以下のセクションを含めること：
  - `## 概要` — 変更の概要
  - `## 変更内容` — 具体的な変更点
  - `## テスト` — テスト実施状況

## 参考ソースの提示
- 回答する際は、関連する公式ドキュメントや参考になるURLを必ず末尾に記載すること
- ソースは以下の形式で記載すること：

```
## 参考
- [ドキュメントタイトル](URL)
```

- 公式ドキュメントが存在する場合は優先して記載すること
- 推測や不確かな情報を提示する場合は、その旨を明記すること

## コードレビュー
- レビューコメントは日本語で、丁寧な表現（です・ます調）を使うこと
- 問題点だけでなく、改善案も具体的に提示すること
- 参考になる公式ドキュメントやベストプラクティスのリンクを添付すること

## 全般
- 不確かな情報は「〜と思われます」「要確認」など明示すること
- 長い説明は見出しや箇条書きを使って構造化すること
