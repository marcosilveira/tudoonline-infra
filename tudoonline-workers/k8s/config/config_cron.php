<?php

date_default_timezone_set('America/Sao_Paulo');


class Conexao
{
    public static $conn = [
        //        'HOST' => '206.189.255.127',
        'HOST' => 'mysql',
        'USER' => 'tudoonline_production',
        'PASSWORD' => '9HUlh2PzRzav5bIHv5FlN3erbApefs6J',
        'DATABASE' => 'tudoonline_production'
    ];
}

$con = mysqli_connect("mysql", "tudoonline_production", "9HUlh2PzRzav5bIHv5FlN3erbApefs6J") or die('Erro ao conectar no MySQL.<br>' . mysqli_connect_error());
mysqli_select_db($con, 'tudoonline_production') or die('Erro ao selecionar o db.<br>' . mysqli_connect_error());

$CONF['painel'] = 'Sistema Grupo Online';

function limpa($txt)
{
    $txt = str_replace("'", "", $txt);
    $txt = str_replace("&", "", $txt);
    $txt = preg_replace(array("/(á|à|ã|â|ä)/", "/(Á|À|Ã|Â|Ä)/", "/(é|è|ê|ë)/", "/(É|È|Ê|Ë)/", "/(í|ì|î|ï)/", "/(Í|Ì|Î|Ï)/", "/(ó|ò|õ|ô|ö)/", "/(Ó|Ò|Õ|Ô|Ö)/", "/(ú|ù|û|ü)/", "/(Ú|Ù|Û|Ü)/", "/(ñ)/", "/(Ñ)/", "/(ç)/", "/(Ç)/"), explode(" ", "a A e E i I o O u U n N c C"), $txt);
    return $txt;
}

// dados da shopify
$SHOPIFY['chave_api'] = 'f2e21896448a8bb42b4ce03bdbfd0b9d';
$SHOPIFY['chave_secreta'] = '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';

function qstatus($st)
{

    $st = trim(strtoupper($st));

    if ($st == 'CANCELLED') {
        return 'Cancelado';
        die;
    } elseif ($st == 'COMPLETED') {
        return 'Entregue para o comprador';
        die;
    } elseif ($st == 'DELIVERED') {
        return 'Entregue';
        die;
    } elseif ($st == 'SHIPPED') {
        return 'Em rota de entrega';
        die;
    } elseif ($st == 'TO_CONFIRM_RECEIVE') {
        return 'Em rota de entrega - Aguardando confirma&ccedil;&atilde;o de entrega';
        die;
    } elseif ($st == 'UNPAID') {
        return 'N&atilde;o pago';
        die;
    } elseif ($st == 'READY_TO_SHIP') {
        return 'Pronto para enviar';
        die;
    } elseif ($st == 'APPROVED') {
        return 'Pagamento Aprovado';
        die;
    }

    return $st;
}