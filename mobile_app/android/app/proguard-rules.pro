# TensorFlow Lite: mantener clases y evitar warnings del delegado GPU
# (referenciadas por reflexión; R8 no las ve y falla el minify de release).
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }
-dontwarn org.tensorflow.lite.gpu.**
