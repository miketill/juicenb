<!DOCTYPE html>
<html>
    <head>
        <title>Juice Notebook</title>
        <link href="css/bootstrap.min.css" rel="stylesheet" media="screen">
        <script src="js/jquery-1.9.0.min.js"></script>
        <script src="js/bootstrap.min.js"></script>
    </head>
    <body>
        <div style='padding-top: 10%'/>
            <div class='container'>
                <div class='row'>
                    <div class='offset9 span3'>
                        <form method='POST' action='/auth'>
                            <fieldset>
                                <input name='login_name' type='text' placeholder='Username or email'>
                                <input name='password' type='password' placeholder='Password'>
                                <input type='submit' value='Sign in' class='btn pull-right'>
                            </fieldset>
                        </form>
                    </div>
                </div>
                <div class='row'>
                    <div class='offset9 span3'>
                        <h4>-or-</h4>
                    </div>
                </div>
                <div class='row'>
                    <div class='offset9 span3'>
                        <form method='POST' action='/users'>
                            <fieldset>
                                <input name='username' type='text' placeholder='Username'>
                                <input name='email' type='text' placeholder='Email'>
                                <input id='np1' name='password' type='password' placeholder='Password'>
                                <input id='np2' type='password' placeholder='Re-enter password'>
                                <input type='submit' value='Create Account' onclick='return $("np1").val() === $("np2").val()'class='btn pull-right'>
                            </fieldset>
                        </form>
                    </div>
                </div>

                <div class='row'>
                    <div class='span1'>
                        x
                    </div>
                    <div class='span1'>
                        x
                    </div>
                    <div class='span1'>
                        x
                    </div>
                    <div class='span1'>
                        x
                    </div>
                    <div class='span1'>
                        x
                    </div>
                    <div class='span1'>
                        x
                    </div>
                    <div class='span1'>
                        x
                    </div>
                    <div class='span1'>
                        x
                    </div>
                    <div class='span1'>
                        x
                    </div>
                    <div class='span1'>
                        x
                    </div>
                    <div class='span1'>
                        x
                    </div>
                    <div class='span1'>
                        x
                    </div>
                </div>
            </div>
        </body>
    </html>
