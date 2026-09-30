#!/usr/bin/env python3
"""Golden model for polynomial multiplication using radix-2 NTT, q=12289, N=256.
This script also prints expected C[0..254] for the sample ROM coefficients.
"""
Q = 12289
N = 256
OMEGA = 8340
OMEGA_INV = 1696
N_INV = pow(N, -1, Q)

# Same sample coefficients as rtl/input_rom_128.v
A = [((3*i*i + 5*i + 7) % Q) for i in range(128)]
B = [((11*i + 13) % Q) for i in range(128)]

def ntt_dif(a, root=OMEGA):
    a = list(a)
    length = N
    while length >= 2:
        half = length // 2
        step = N // length
        for start in range(0, N, length):
            for j in range(half):
                u = a[start+j]
                v = a[start+j+half]
                a[start+j] = (u + v) % Q
                a[start+j+half] = ((u - v) * pow(root, j*step, Q)) % Q
        length //= 2
    return a

def intt_dit(a, root_inv=OMEGA_INV):
    a = list(a)
    length = 2
    while length <= N:
        half = length // 2
        step = N // length
        for start in range(0, N, length):
            for j in range(half):
                u = a[start+j]
                v = (a[start+j+half] * pow(root_inv, j*step, Q)) % Q
                a[start+j] = (u + v) % Q
                a[start+j+half] = (u - v) % Q
        length *= 2
    return [(x * N_INV) % Q for x in a]

def schoolbook(a, b):
    c = [0] * 255
    for i, ai in enumerate(a):
        for j, bj in enumerate(b):
            c[i+j] = (c[i+j] + ai * bj) % Q
    return c

def ntt_multiply(a, b):
    aa = a + [0]*(N-len(a))
    bb = b + [0]*(N-len(b))
    Ahat = ntt_dif(aa)
    Bhat = ntt_dif(bb)
    Chat = [(x*y) % Q for x, y in zip(Ahat, Bhat)]
    c = intt_dit(Chat)
    return c[:255]

if __name__ == "__main__":
    c1 = schoolbook(A, B)
    c2 = ntt_multiply(A, B)
    print("q=", Q, "N=", N, "omega=", OMEGA, "omega_inv=", OMEGA_INV, "N_INV=", N_INV)
    print("match=", c1 == c2)
    if c1 != c2:
        for i, (x, y) in enumerate(zip(c1, c2)):
            if x != y:
                print("first mismatch", i, x, y)
                break
    print("Expected C[0..254]:")
    for i, x in enumerate(c1):
        print(f"C[{i:03d}] = {x:05d}")
