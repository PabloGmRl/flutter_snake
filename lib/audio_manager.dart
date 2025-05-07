import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playEatSound() async {
    await _player.play(AssetSource('sonidos/food.mp3'));
  }

  static Future<void> playLoseSound() async {
    await _player.play(AssetSource('sonidos/gameover.mp3'));
  }

  static Future<void> playWinSound() async {
    await _player.play(AssetSource('sonidos/victoria.mp3'));
  }

  static Future<void> playMoveSound() async {
    await _player.play(AssetSource('sonidos/move.mp3'));
  }
}