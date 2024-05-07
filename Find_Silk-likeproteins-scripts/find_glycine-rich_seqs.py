from Bio import SeqIO
from collections import deque
import argparse

def identify_silk_like_proteins(fasta_file, window_size=80, min_glycine_percentage=25):
    for record in SeqIO.parse(fasta_file, 'fasta'):
        sequence = str(record.seq)
        if has_silk_like_sequence(sequence, window_size, min_glycine_percentage):
            print(f">{record.id}\n{sequence}")

def has_silk_like_sequence(sequence, window_size, min_glycine_percentage):
    glycine_count = 0
    window = deque(maxlen=window_size)

    for aa in sequence:
        window.append(aa)
        if aa == 'G':
            glycine_count += 1

        if len(window) == window_size:
            if (glycine_count / window_size) * 100 >= min_glycine_percentage:
                return True

            # Remove the first amino acid from the window
            if window[0] == 'G':
                glycine_count -= 1
            window.popleft()

    return False

def main():
    parser = argparse.ArgumentParser(description='Identify silk-like proteins from a FASTA file.')
    parser.add_argument('fasta_file', help='Input FASTA file containing protein sequences')
    parser.add_argument('--window-size', type=int, default=80, help='Size of the sliding window')
    parser.add_argument('--min-glycine-percentage', type=int, default=25, help='Minimum percentage of glycine within the window')

    args = parser.parse_args()
    identify_silk_like_proteins(args.fasta_file, args.window_size, args.min_glycine_percentage)

if __name__ == '__main__':
    main()

