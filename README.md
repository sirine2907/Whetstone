# Whetstone

**Turn a rough idea into a sharp prompt.** Whetstone is a Flutter app for Android and Windows. Type a messy request and it rewrites it into a clear prompt you can paste into any AI assistant. It also shows you which parts your prompt is missing.

<p align="center">
  <img src="docs/demo.gif" width="300" alt="Demo: sharpening a prompt, filling a template, history and dark mode" />
</p>

## Screenshots

| Sharpen | Result | Templates |
|:---:|:---:|:---:|
| <img src="docs/screenshots/01_sharpen.png" width="240" /> | <img src="docs/screenshots/02_result.png" width="240" /> | <img src="docs/screenshots/03_templates.png" width="240" /> |
| **Template detail** | **History** | **Settings** |
| <img src="docs/screenshots/04_template_detail.png" width="240" /> | <img src="docs/screenshots/05_history.png" width="240" /> | <img src="docs/screenshots/06_settings.png" width="240" /> |
| **Dark result** | **Dark templates** | |
| <img src="docs/screenshots/07_dark_result.png" width="240" /> | <img src="docs/screenshots/08_dark_templates.png" width="240" /> | |

## Features

- **Prompt rewriting with Claude.** Add your own API key and the rewrite streams in as it is generated.
- **Three focus modes.** Clear is short and direct, Detailed spells out depth and examples, and Structured uses labelled sections.
- **Offline drafts.** With no key, the app wraps your prompt in a good structure and leaves `[brackets]` for you to fill in. If a Claude request fails, you can switch to a draft from the error message.
- **Sharpness meter.** A live check for the five parts of a good prompt: role, task, context, format and limits.
- **12 templates** across Writing, Code, Work and Study, with search, category filters and a live preview.
- **History.** Every result is saved on the device, and you can search it, star items, swipe to delete, or tap to reopen one.
- **Light, dark and system themes.**

## How it works

1. `SharpenProvider` reads the input and checks whether there is an API key.
2. With a key, `ClaudeService` sends a streaming request to the Claude Messages API. Dart has no official SDK, so this is a plain `http` request, and the response is read line by line as server-sent events.
3. Without a key, `LocalSharpener` picks a role from keywords in the prompt and fills a fixed structure for the chosen focus.
4. The finished result goes to `HistoryProvider`, which saves it as JSON in `shared_preferences`.

The meter is `PromptChecker`, a set of keyword patterns. It is a quick hint and doesn't understand the prompt, so a high score doesn't guarantee a good prompt. Unfilled `[brackets]` don't count towards the score.

## Privacy

Without an API key, nothing leaves the device. With a key, your prompt is sent to the Claude API and usage is billed to your Anthropic account. The key is kept in `flutter_secure_storage` rather than `shared_preferences`, and it is only sent to `api.anthropic.com`.

## Tech stack

| | |
|---|---|
| Framework | Flutter 3.38, Dart |
| State | Provider |
| Network | http, with streaming |
| Storage | shared_preferences, flutter_secure_storage |
| Model | Claude Opus 5.5 (`claude-opus-5-5`) |

## Getting started

```bash
git clone https://github.com/sirine2907/-Whetstone.git
cd -- -Whetstone
flutter pub get
flutter run
```

The app works straight away with offline drafts. To use Claude, create an API key at [console.anthropic.com](https://console.anthropic.com) and paste it into **Settings**.

## Project structure

```
lib/
  data/        the template list
  models/      SharpenedPrompt, PromptTemplate
  providers/   nav, settings, history and sharpen state
  screens/     one file per screen
  services/    ClaudeService, LocalSharpener, PromptChecker
  widgets/     sharpness meter, result card
  theme.dart   colors and the light and dark themes
```

## Tests

```bash
flutter test test/prompt_checker_test.dart test/claude_service_test.dart test/app_test.dart
```

The API tests use a fake HTTP client, so they make no network calls and need no key.

The screenshots above come from golden tests that render each screen. To update them:

```bash
flutter test test/screenshots --update-goldens
```

The demo GIF is recorded the same way, then the frames are joined with Pillow:

```bash
flutter test test/screenshots/demo_test.dart --update-goldens
python tool/make_demo_gif.py
```

The demo runs in offline mode, so it shows offline drafts rather than Claude rewrites.

## License

MIT, see [LICENSE](LICENSE). The bundled Inter and Fraunces fonts are under the SIL Open Font License, included in [assets/fonts](assets/fonts).
