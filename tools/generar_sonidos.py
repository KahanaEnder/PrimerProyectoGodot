#!/usr/bin/env python3
"""Genera WAV placeholder para efectos de sonido del juego."""
import math
import os
import struct
import wave

SR = 44100
SALIDA = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "assets", "sonidos"))


def escribir(archivo: str, muestras: list[float]) -> None:
    ruta = os.path.join(SALIDA, archivo)
    with wave.open(ruta, "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(b"".join(struct.pack("<h", int(max(-1.0, min(1.0, m)) * 32767)) for m in muestras))
    print("WAV generado:", ruta)


def salto() -> None:
    dur = 0.15
    n = int(SR * dur)
    out = []
    for i in range(n):
        t = i / SR
        f = 300.0 + (600.0 - 300.0) * (i / n)
        env = 1.0 - (i / n)
        out.append(math.sin(2 * math.pi * f * t) * 0.5 * env)
    escribir("salto.wav", out)


def muerte() -> None:
    dur = 0.45
    n = int(SR * dur)
    out = []
    for i in range(n):
        t = i / SR
        frac = i / n
        f = 220.0 - 140.0 * frac
        env = (1.0 - frac) ** 2
        s = math.sin(2 * math.pi * f * t) + 0.4 * math.sin(2 * math.pi * 1.5 * f * t)
        out.append(s * 0.6 * env)
    escribir("muerte.wav", out)


def victoria() -> None:
    notas = [523.25, 659.25, 783.99, 1046.5]
    seg_nota = 0.14
    out = []
    for f in notas:
        n = int(SR * seg_nota)
        for j in range(n):
            t = j / SR
            env = min(1.0, j / (0.01 * SR)) * (1.0 - j / n)
            out.append(math.sin(2 * math.pi * f * t) * 0.5 * env)
    out += [0.0] * int(SR * 0.12)
    escribir("victoria.wav", out)


if __name__ == "__main__":
    os.makedirs(SALIDA, exist_ok=True)
    salto()
    muerte()
    victoria()