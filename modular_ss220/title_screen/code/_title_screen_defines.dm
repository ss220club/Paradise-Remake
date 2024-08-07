#define DEFAULT_TITLE_SCREEN_IMAGE_PATH 'modular_ss220/title_screen/icons/default.gif'

#define DEFAULT_TITLE_HTML {"
	<html>
		<head>
			<meta http-equiv="X-UA-Compatible" content="IE=edge">
			<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
			<title>Title Screen</title>
			<style type='text/css'>
				@font-face {
					font-family: "Fixedsys";
					src: url("FixedsysExcelsior3.01Regular.ttf");
				}
				body,
				html {
					margin: 0;
					overflow: hidden;
					text-align: center;
					background-color: black;
					padding-top: 5vmin;
					-ms-user-select: none;
					cursor: default;
				}

				img {
					border-style:none;
				}

				.bg {
					position: absolute;
					width: auto;
					height: 100vmin;
					min-width: 100vmin;
					min-height: 100vmin;
					top: 50%;
					left:50%;
					transform: translate(-50%, -50%);
					z-index: 0;
				}

				.container_notice {
					position: absolute;
					box-sizing: border-box;
					width: auto;
					padding-top: 1vmin;
					top: calc(50% - 10vmin);
					left:50%;
					transform: translate(-50%, -50%);
					z-index: 1;
				}

				.menu_notice {
					display: inline-block;
					font-family: "Fixedsys";
					font-weight: lighter;
					text-decoration: none;
					width: 100%;
					text-align: left;
					color: red;
					text-shadow: 1px 0px black, -1px 0px black, 0px 1px black, 0px -1px black, 2px 0px black, -2px 0px black, 0px 2px black, 0px -2px black;
					margin-right: 0%;
					margin-top: 0px;
					font-size: 3vmin;
					line-height: 2vmin;
				}

				.container_nav {
					position: absolute;
					box-sizing: border-box;
					width: 90vmin;
					min-height: 10vmin;
					top: calc(50% + 22.5vmin);
					left:50%;
					transform: translate(-50%, -50%);
					z-index: 1;
					border: 2px solid white;
					border-radius: 4px;
					box-shadow: 2px 2px #333, inset 1px 1px #333;
					background: linear-gradient(to bottom, rgba(68, 68, 204, 0.9), rgba(0, 0, 102, 0.9));
					opacity: 75%;
					padding: 1em;
				}

				.container_nav hr {
					height: 2px;
					background-color: #cde;
					border: none;
					box-shadow: 2px 2px black;
				}

				.menu_button {
					display: block;
					box-sizing: border-box;
					font-family: "Fixedsys";
					font-weight: lighter;
					text-decoration: none;
					font-size: 4vmin;
					text-shadow: 2px 2px black;
					line-height: 4vmin;
					width: 100%;
					text-align: left;
					color: #cde;
					height: 4vmin;
					padding-left: 5vmin;
					letter-spacing: 1px;
					cursor: pointer;
					white-space: nowrap;
					overflow: hidden;
				}

				.menu_button:hover {
					padding-left: 0px;
					color: yellow;
				}

				.menu_button:active {
					padding-left: 0px;
					transform: translate(2px, 2px);
				}

				.menu_button:hover::before {
					content: "☞";
					text-align: center;
					width: 5vmin;
					display: inline-block;
				}

				@keyframes pulse_button {
					0% {transform: translateX(0px);}
					100% {transform: translateX(2px);}
				}

				.menu_button:active::before {
					content: "☛";
					text-align: center;
					width: 5vmin;
					animation: pulse_button 0.25s infinite alternate;
				}

				@keyframes pollsbox {
					0% {color: #cde;}
					50% {color: #f80;}
				}

				.menu_newpoll {
					animation: pollsbox 2s step-start infinite;
					padding-left: 0px;
				}

				.menu_newpoll::before {
					content: "→";
					text-align: center;
					width: 5vmin;
					display: inline-block;
				}

				.menu_newpoll::after {
					content: "←";
					text-align: center;
					width: 5vmin;
					display: inline-block;
				}

				.container_notice {
					position: absolute;
					box-sizing: border-box;
					width: auto;
					padding-top: 1vmin;
					top: calc(50% - 10vmin);
					left:50%;
					transform: translate(-50%, -50%);
					z-index: 1;
				}

				.menu_notice {
					display: inline-block;
					font-family: "Fixedsys";
					font-weight: lighter;
					text-decoration: none;
					width: 100%;
					text-align: left;
					color: red;
					text-shadow: 1px 0px black, -1px 0px black, 0px 1px black, 0px -1px black, 2px 0px black, -2px 0px black, 0px 2px black, 0px -2px black;
					margin-right: 0%;
					margin-top: 0px;
					font-size: 3vmin;
					line-height: 2vmin;
				}

				.unchecked {
					color: #F44;
				}

				.checked {
					color: #4F4;
				}
			</style>
		</head>
		<body>
			"}
