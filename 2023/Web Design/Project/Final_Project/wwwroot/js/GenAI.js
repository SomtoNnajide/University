$(document).ready(function () {
    $(function () {
        $("#toolsGrid").elastic_grid({
            'showAllText': 'All',
            'filterEffect': 'popup',
            'hoverDirection': true,
            'hoverDelay': 0,
            'hoverInverse': false,
            'expandingSpeed': 500,
            'expandingHeight': 150,
            'items':
                [
                    {
                        'title': '<div id="eg-popup-header">ChatGPT</div> <div id="eg-border-separator"></div> <a class="btn btn-primary">More Details</a>',
                        'description': '<h4>ChatGPT is a large language model-based chatbot developed by OpenAI and launched on November 30, 2022, notable for enabling users to refine and steer a conversation towards a desired length, format, style, level of detail, and language used. (Wikipedia)</h4> ',
                        'thumbnail': ['/images/genai/chatgpt_thumbnail.jpg'],
                        'large': ['/images/genai/chatgpt_large.jpg'],
                        'button_list':
                        [
                                { 'title': 'Visit Website', 'url': 'https://openai.com/blog/chatgpt', 'new_window': true },
                        ],
                        'tags': ['none']
                    },
                    {
                        'title': '<div id="eg-popup-header">Bard</div> <div id="eg-border-separator"></div> <a class="btn btn-primary">More Details</a>',
                         'description': '<h4>Bard is a conversational generative artificial intelligence chatbot developed by Google, based initially on the LaMDA family of large language models and later the PaLM LLM.  (Wikipedia)</h4 > ',
                        'thumbnail': ['/images/genai/bard_thumbnail.jpg'],
                        'large': ['/images/genai/bard_large.jpg'],
                        'button_list':
                        [
                                { 'title': 'Visit Website', 'url': 'https://bard.google.com/', 'new_window': true },
                        ],
                        'tags': ['none']
                    },
                    {
                        'title': '<div id="eg-popup-header">Midjourney</div> <div id="eg-border-separator"></div> <a class="btn btn-primary">More Details</a>',
                        'description': '<h4>Midjourney is a generative artificial intelligence program and service created and hosted by San Francisco-based independent research lab Midjourney, Inc. (Wikipedia)</h4 > ',
                        'thumbnail': ['/images/genai/midjourney_thumbnail.jpg'],
                        'large': ['/images/genai/midjourney_large.jpg'],
                        'button_list':
                            [
                                { 'title': 'Visit Website', 'url': 'https://www.midjourney.com/home/?callbackUrl=%2Fapp%2F', 'new_window': true },
                            ],
                        'tags': ['none']
                    },
                    {
                        'title': '<div id="eg-popup-header">DALL-E</div> <div id="eg-border-separator"></div> <a class="btn btn-primary">More Details</a>',
                        'description': '<h4>DALL-E and DALL-E 2 are text-to-image models developed by OpenAI using deep learning methodologies to generate digital images from natural language descriptions, called prompts (Wikipedia)</h4 > ',
                        'thumbnail': ['/images/genai/dalle_thumbnail.jpg'],
                        'large': ['/images/genai/dalle_large.jpg'],
                        'button_list':
                            [
                                { 'title': 'Visit Website', 'url': 'https://openai.com/dall-e-2', 'new_window': true },
                            ],
                        'tags': ['none']
                    },
                ]
        });
        $("#orgsGrid").elastic_grid({
            'showAllText': 'All',
            'filterEffect': 'popup',
            'hoverDirection': true,
            'hoverDelay': 0,
            'hoverInverse': false,
            'expandingSpeed': 500,
            'expandingHeight': 150,
            'items':
                [
                    {
                        'title': '<div id="eg-popup-header">Mircosoft</div> <div id="eg-border-separator"></div> <a class="btn btn-primary">More Details</a>',
                        'description': '<h4>Microsoft Corporation is an American multinational technology corporation headquartered in Redmond, Washington. Microsofts best-known software products are the Windows line of operating systems, the Microsoft 365 suite of productivity applications, and the Internet Explorer and Edge web browsers. (Wikipedia)</h4> ',
                        'thumbnail': ['/images/genai/ms_thumbnail.jpg'],
                        'large': ['/images/genai/ms_large.jpg'],
                        'button_list':
                            [
                                { 'title': 'Visit Website', 'url': 'https://www.microsoft.com/en-au', 'new_window': true },
                            ],
                        'tags': ['none']
                    },
                    {
                        'title': '<div id="eg-popup-header">Google LLC </div> <div id="eg-border-separator"></div> <a class="btn btn-primary">More Details</a>',
                        'description': '<h4>Google LLC is an American multinational technology company focusing on artificial intelligence, online advertising, search engine technology, cloud computing, computer software, quantum computing, e-commerce, and consumer electronics. (Wikipedia)</h4 > ',
                        'thumbnail': ['/images/genai/google_thumbnail.jpg'],
                        'large': ['/images/genai/google_large.jpg'],
                        'button_list':
                            [
                                { 'title': 'Visit Website', 'url': 'https://about.google/?fg=1&utm_source=google-AU&utm_medium=referral&utm_campaign=hp-header', 'new_window': true },
                            ],
                        'tags': ['none']
                    },
                    {
                        'title': '<div id="eg-popup-header">IBM</div> <div id="eg-border-separator"></div> <a class="btn btn-primary">More Details</a>',
                        'description': '<h4>The International Business Machines Corporation, nicknamed Big Blue, is an American multinational technology corporation headquartered in Armonk, New York and is present in over 175 countries. (Wikipedia)</h4 > ',
                        'thumbnail': ['/images/genai/ibm_thumbnail.jpg'],
                        'large': ['/images/genai/ibm_large.jpg'],
                        'button_list': 
                            [
                                { 'title': 'Visit Website', 'url': 'https://www.ibm.com/au-en', 'new_window': true },
                            ],
                        'tags': ['none']
                    },
                    {
                        'title': '<div id="eg-popup-header">Amazon</div> <div id="eg-border-separator"></div> <a class="btn btn-primary">More Details</a>',
                        'description': '<h4>Amazon.com, Inc. is an American multinational technology company focusing on e-commerce, cloud computing, online advertising, digital streaming, and artificial intelligence. (Wikipedia)</h4 > ',
                        'thumbnail': ['/images/genai/amazon_thumbnail.jpg'],
                        'large': ['/images/genai/amazon_large.jpg'],
                        'button_list':
                            [
                                { 'title': 'Visit Website', 'url': 'https://www.amazon.com.au/', 'new_window': true },
                            ],
                        'tags': ['none']
                    },
                ]
        });
        $("#applicationsGrid").elastic_grid({
            'showAllText': 'All',
            'filterEffect': 'popup',
            'hoverDirection': true,
            'hoverDelay': 0,
            'hoverInverse': false,
            'expandingSpeed': 500,
            'expandingHeight': 150,
            'items':
                [
                    {
                        'title': '<div id="eg-popup-header">ChatGPT</div> <div id="eg-border-separator"></div> <a class="btn btn-primary">More Details</a>',
                        'description': '<h4>ChatGPT is a large language model-based chatbot developed by OpenAI and launched on November 30, 2022, notable for enabling users to refine and steer a conversation towards a desired length, format, style, level of detail, and language used. (Wikipedia)</h4> ',
                        'thumbnail': ['/images/genai/chatgpt_thumbnail.jpg'],
                        'large': ['/images/genai/chatgpt_large.jpg'],
                        'button_list':
                            [
                                { 'title': 'Visit Website', 'url': 'https://openai.com/blog/chatgpt', 'new_window': true },
                            ],
                        'tags': ['none']
                    },
                    {
                        'title': '<div id="eg-popup-header">Github Copilot</div> <div id="eg-border-separator"></div> <a class="btn btn-primary">More Details</a>',
                        'description': '<h4>GitHub Copilot is a cloud-based artificial intelligence tool developed by GitHub and OpenAI to assist users of Visual Studio Code, Visual Studio, Neovim, and JetBrains integrated development environments by autocompleting code. (Wikipedia)</h4 > ',
                        'thumbnail': ['/images/genai/githubcopilot_thumbnail.jpg'],
                        'large': ['/images/genai/githubcopilot_large.jpg'],
                        'button_list':
                            [
                                { 'title': 'Visit Website', 'url': 'https://github.com/features/copilot', 'new_window': true },
                            ],
                        'tags': ['none']
                    },
                    {
                        'title': '<div id="eg-popup-header">DALL-E</div> <div id="eg-border-separator"></div> <a class="btn btn-primary">More Details</a>',
                        'description': '<h4>DALL-E and DALL-E 2 are text-to-image models developed by OpenAI using deep learning methodologies to generate digital images from natural language descriptions, called prompts (Wikipedia)</h4 > ',
                        'thumbnail': ['/images/genai/dalle_thumbnail.jpg'],
                        'large': ['/images/genai/dalle_large.jpg'],
                        'button_list':
                            [
                                { 'title': 'Visit Website', 'url': 'https://openai.com/dall-e-2', 'new_window': true },
                            ],
                        'tags': ['none']
                    },
                    {
                        'title': '<div id="eg-popup-header">Video: Synthesia</div> <div id="eg-border-separator"></div> <a class="btn btn-primary">More Details</a>',
                        'description': '<h4>Synthesia is a synthetic media generation platform used to create AI generated video content. Based in London, England, it counts among its users businesses including Amazon, Tiffany & Co. and IHG Hotels & Resorts. (Wikipedia)</h4 > ',
                        'thumbnail': ['/images/genai/synthesia_thumbnail.jpg'],
                        'large': ['/images/genai/synthesia_large.jpg'],
                        'button_list':
                            [
                                { 'title': 'Visit Website', 'url': 'https://synthesiagame.com/', 'new_window': true },
                            ],
                        'tags': ['none']
                    },
                ]
        });
    });
});