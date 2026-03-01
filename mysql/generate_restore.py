import sys

def process_binlog(input_file, output_file):
    with open(input_file, 'r', encoding='utf-8', errors='replace') as infile, \
         open(output_file, 'w', encoding='utf-8') as outfile:
        
        current_values = []
        in_delete = False
        
        for line in infile:
            line = line.strip()
            
            if line.startswith('### DELETE FROM `tudoonline_production`.`produtos`'):
                if current_values:
                    outfile.write("INSERT INTO `tudoonline_production`.`produtos` VALUES (" + ", ".join(current_values) + ");\n")
                    current_values = []
                in_delete = True
                continue
                
            if not in_delete:
                continue
                
            if line == '### WHERE':
                continue
                
            if line.startswith('###   @'):
                # Extract value
                eq_idx = line.find('=')
                comment_idx = line.rfind(' /* ')
                if eq_idx != -1:
                    if comment_idx > eq_idx:
                        val = line[eq_idx+1:comment_idx]
                    else:
                        val = line[eq_idx+1:]
                    current_values.append(val)
            else:
                # Any other line breaks the delete block
                if current_values:
                    outfile.write("INSERT INTO `tudoonline_production`.`produtos` VALUES (" + ", ".join(current_values) + ");\n")
                    current_values = []
                in_delete = False

        # Flush any remaining at EOF
        if current_values:
            outfile.write("INSERT INTO `tudoonline_production`.`produtos` VALUES (" + ", ".join(current_values) + ");\n")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Uso: python3 generate_restore.py <input.txt> <output.sql>")
        sys.exit(1)
        
    process_binlog(sys.argv[1], sys.argv[2])
    print(f"Processamento concluído. Verifique o arquivo {sys.argv[2]}")
