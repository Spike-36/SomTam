# My Flashcards (Flutter Starter)

This starter shows:
- Loading cards from `assets/cards.json`
- Playing local audio with `just_audio`
- Playing local video with `video_player`

## Quick start
1) Install Flutter and run `flutter doctor`.
2) Create a new project (or unzip this folder inside your workspace).
3) Run:
   flutter pub get
   flutter run

## Add your media
- Put MP3 files in `assets/audio/` and PNG/JPG in `assets/images/`, MP4 in `assets/video/`.
- Update `assets/cards.json` to point to your files.
- Example entry:
  {
    "id": 1,
    "term": "Hello",
    "meaning": "A greeting",
    "image": "assets/images/hello.png",
    "audio": "assets/audio/hello.mp3",
    "video": "assets/video/hello.mp4"
  }

## Notes
- Buttons will attempt to play files listed in JSON. If you haven't added the files yet,
  you'll see a log error in the console.
- For background audio, later add the `audio_service` package.
