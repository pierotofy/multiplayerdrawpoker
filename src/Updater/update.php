<?php

$buffer = "";
$op_count = 0;

function mk_dir($dir){
 global $buffer, $op_count;
 $buffer .= "MKDIR¿$dir\n";
 $op_count++;
}

function rm_dir($dir){
 global $buffer, $op_count;
 $buffer .= "RMDIR¿$dir\n";
 $op_count++;
}

function cp_file($source, $dest){
 global $buffer, $op_count;
 $buffer .= "CPFILE¿".$source."¿$dest\n";
 $op_count++;
}

function rm_file($file){
 global $buffer, $op_count;
 $buffer .= "RMFILE¿".$file. "\n";
 $op_count++;
}

function show_message($message, $timeout){
 global $buffer, $op_count;
 $buffer .= "SHOWMESSAGE¿".$message."¿$timeout\n";
 $op_count++;
}

function launch($apppath){
 global $buffer, $op_count;
 $buffer .= "LAUNCH¿$apppath\n";
 $op_count++;
}

function ren($old, $new){
 global $buffer, $op_count;
 $buffer .= "REN¿".$old."¿$new\n";
 $op_count++;
}



//Lista operazioni...
cp_file("http://www.pierotofy.it/index.php","~\\prova.htm");
show_message("file copiato!",2000);
ren("~\\prova.htm","~\\hehe.htm");



echo "2.0 beta\n";
echo $op_count . "\n";
echo $buffer;



?>

