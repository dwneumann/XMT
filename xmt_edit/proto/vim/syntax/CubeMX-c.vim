" colorize user-generated code regions in auto-generated files
" the UserCode syntax group is only defined in colorscheme xmt
syntax region USERCODE start=/\/\* *USER CODE BEGIN/  end=/\/\* *USER CODE END .*/
highlight link USERCODE UserCode
