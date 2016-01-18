<?php
$to = "absender@yourdomain.de";
$subject = "Contact Us";
$email = $_REQUEST['email'] ;
$message = $_REQUEST['message'] ;
$headers = "From: $email";
$sent = mail($to, $subject, $message, $headers) ;
if($sent)
{print "Ihre E-Mail wurde versand,"; }
else
{print "Beim Versand der E-Mail trat leider ein Problem auf."; }
?> 