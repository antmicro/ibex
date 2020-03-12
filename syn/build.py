#!/usr/bin/env python3

import edalize
import os

work_root = 'build_eda'
src_dir = "syn_out_07_02_2020_15_30_31/generated/"

files = [
]
for file in os.listdir(src_dir):
    if file.endswith(".v"):
        src = {'name' : os.path.abspath(os.path.join(src_dir, file)), 'file_type' : 'verilogSource'}
        files.append(src)
src = {'name' : os.path.abspath(os.path.join("pins_artya7.xdc")), 'file_type' : 'xdc'}
files.append(src)

tool = 'vivado'

parameters = {}

edam = {
  'files' : files,
  'name'  : 'lowrisc_ibex_top_artya7',
  'toplevel': 'top',
  'tool_options' : {'vivado' : {
    'part' : 'xc7a35ticsg324-1L',
    'synth' : 'yosys'
    }}
}

backend = edalize.get_edatool(tool)(edam=edam, work_root=work_root)

os.makedirs(work_root, exist_ok = True)
backend.configure("")
backend.build()
