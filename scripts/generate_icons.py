#!/usr/bin/env python3
"""Generate simple placeholder PNG icons for the PWA manifest"""

import struct
import zlib
import os

def create_png(filename, width, height, bg_color=(10, 10, 10), fg_color=(51, 255, 51)):
    """
    Create a simple PNG file with solid background color
    bg_color: RGB tuple for background (default: dark background #0a0a0a)
    fg_color: RGB tuple for optional foreground (default: green #33ff33)
    """
    
    # Create image data - solid color for now
    # Each pixel is RGB (3 bytes), each row starts with filter type (1 byte)
    rows = []
    for y in range(height):
        row = [0]  # Filter type: None
        for x in range(width):
            # Simple pattern: solid background
            row.extend(bg_color)
        rows.append(bytes(row))
    
    raw_data = b''.join(rows)
    
    # Compress the data
    compressed = zlib.compress(raw_data, 9)
    
    # PNG file structure
    def chunk(chunk_type, data):
        """Create a PNG chunk"""
        chunk_data = chunk_type + data
        crc = zlib.crc32(chunk_data) & 0xffffffff
        return struct.pack('!I', len(data)) + chunk_data + struct.pack('!I', crc)
    
    # Build PNG file
    png_data = b'\x89PNG\r\n\x1a\n'  # PNG signature
    
    # IHDR chunk (image header)
    ihdr = struct.pack('!IIBBBBB', width, height, 8, 2, 0, 0, 0)
    # width, height, bit_depth=8, color_type=2 (RGB), compression=0, filter=0, interlace=0
    png_data += chunk(b'IHDR', ihdr)
    
    # IDAT chunk (image data)
    png_data += chunk(b'IDAT', compressed)
    
    # IEND chunk (end of file)
    png_data += chunk(b'IEND', b'')
    
    # Write to file
    with open(filename, 'wb') as f:
        f.write(png_data)
    
    print(f"Created {filename} ({width}x{height})")

def main():
    # Create icons directory if it doesn't exist
    script_dir = os.path.dirname(os.path.abspath(__file__))
    icons_dir = os.path.join(os.path.dirname(script_dir), 'web', 'icons')
    os.makedirs(icons_dir, exist_ok=True)
    
    # Dark background color (#0a0a0a) for all icons
    bg = (10, 10, 10)
    fg = (51, 255, 51)  # Green
    
    # Generate required icons
    create_png(os.path.join(icons_dir, 'icon-192.png'), 192, 192, bg, fg)
    create_png(os.path.join(icons_dir, 'icon-512.png'), 512, 512, bg, fg)
    create_png(os.path.join(icons_dir, 'icon-maskable-512.png'), 512, 512, bg, fg)
    
    print(f"\nIcons generated in: {icons_dir}")
    print("Note: These are placeholder icons. Consider creating proper icons with a design tool.")

if __name__ == '__main__':
    main()
