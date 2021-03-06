.section .game.data 

	player_won_message: .asciz "__   __                                  _   _                                         _ 
\\ \\ / /                                 | | | |                                       | |
 \\ V /___  _   _  __      _____  _ __   | |_| |__   ___    __ _  __ _ _ __ ___   ___  | |
  \\ // _ \\| | | | \\ \\ /\\ / / _ \\| '_ \\  | __| '_ \\ / _ \\  / _` |/ _` | '_ ` _ \\ / _ \\ | |
  | | (_) | |_| |  \\ V  V / (_) | | | | | |_| | | |  __/ | (_| | (_| | | | | | |  __/ |_|
  \\_/\\___/ \\__,_|   \\_/\\_/ \\___/|_| |_|  \\__|_| |_|\\___|  \\__, |\\__,_|_| |_| |_|\\___| (_)
                                                           __/ |                         
                                                          |___/                          "

    
    player_dead_message: .asciz "Press Q to return to the main menu\n _____                     _             _                        
|  ___|                   (_)           | |                       
| |__ _ __   ___ _ __ ___  _  ___  ___  | |__   __ ___   _____    
|  __| '_ \\ / _ \\ '_ ` _ \\| |/ _ \\/ __| | '_ \\ / _` \\ \\ / / _ \\   
| |__| | | |  __/ | | | | | |  __/\\__ \\ | | | | (_| |\\ V /  __/   
\\____/_| |_|\\___|_| |_| |_|_|\\___||___/ |_| |_|\\__,_| \\_/ \\___|   
                                                                  
                                                                  
 _                _                                   _           
| |              | |                                 | |          
| |__   ___  __ _| |_ ___ _ __    _   _  ___  _   _  | |__  _   _ 
| '_ \\ / _ \\/ _` | __/ _ \\ '_ \\  | | | |/ _ \\| | | | | '_ \\| | | |
| |_) |  __/ (_| | ||  __/ | | | | |_| | (_) | |_| | | |_) | |_| |
|_.__/ \\___|\\__,_|\\__\\___|_| |_|  \\__, |\\___/ \\__,_| |_.__/ \\__, |
                                   __/ |                     __/ |
                                  |___/                     |___/ 
          __           _                      __   _____          
         / _|         | |                    / _| / __  \\         
  __ _  | |_ __ _  ___| |_ ___  _ __    ___ | |_  `' / /'         
 / _` | |  _/ _` |/ __| __/ _ \\| '__|  / _ \\|  _|   / /           
| (_| | | || (_| | (__| || (_) | |    | (_) | |   ./ /___         
 \\__,_| |_| \\__,_|\\___|\\__\\___/|_|     \\___/|_|   \\_____/         
                                                                  
                                                                                                                                                                                          
"

    tutorial: .asciz " _____     _             _       _ 
|_   _|   | |           (_)     | |
  | |_   _| |_ ___  _ __ _  __ _| |
  | | | | | __/ _ \\| '__| |/ _` | |
  | | |_| | || (_) | |  | | (_| | |
  \\_/\\__,_|\\__\\___/|_|  |_|\\__,_|_|\n\nYou have to press A and D to control the space ship.
Good luck!\nEach ship that you destroy gives you points.Press W to shoot (or E if you are lazy) and have fun!
You know the rules, and so do I: https://www.youtube.com/watch?v=GaAUS0GsG_M"


pattern_big_fat_bus: .asciz " _____ _            _     _          __      _     _                 _                           _                __                               
|_   _| |          | |   (_)        / _|    | |   | |               (_)                         (_)              / _|                              
  | | | |__   ___  | |__  _  __ _  | |_ __ _| |_  | |__  _   _ ___   _ ___    ___ ___  _ __ ___  _ _ __   __ _  | |_ ___  _ __   _   _  ___  _   _ 
  | | | '_ \\ / _ \\ | '_ \\| |/ _` | |  _/ _` | __| | '_ \\| | | / __| | / __|  / __/ _ \\| '_ ` _ \\| | '_ \\ / _` | |  _/ _ \\| '__| | | | |/ _ \\| | | |
  | | | | | |  __/ | |_) | | (_| | | || (_| | |_  | |_) | |_| \\__ \\ | \\__ \\ | (_| (_) | | | | | | | | | | (_| | | || (_) | |    | |_| | (_) | |_| |
  \\_/ |_| |_|\\___| |_.__/|_|\\__, | |_| \\__,_|\\__| |_.__/ \\__,_|___/ |_|___/  \\___\\___/|_| |_| |_|_|_| |_|\\__, | |_| \\___/|_|     \\__, |\\___/ \\__,_| 
                             __/ |                                                                        __/ |                   __/ |            
                            |___/                                                                        |___/                   |___/             "

.data
player_static_won: .asciz "__   __                                _                                    
\\ \\ / /                               | |                                   
 \\ V /___  _   _  __      _____  _ __ | |                                   
  \\ // _ \\| | | | \\ \\ /\\ / / _ \\| '_ \\| |                                   
  | | (_) | |_| |  \\ V  V / (_) | | | |_|                                   
  \\_/\\___/ \\__,_|   \\_/\\_/ \\___/|_| |_(_)                                   
                                                                            
                                                                            
 _   _                 _                        _                           
| \\ | |               | |                      | |                          
|  \\| | _____      __ | |_ _ __ _   _    __ _  | |__   ___  _ __  _   _ ___ 
| . ` |/ _ \\ \\ /\\ / / | __| '__| | | |  / _` | | '_ \\ / _ \\| '_ \\| | | / __|
| |\\  | (_) \\ V  V /  | |_| |  | |_| | | (_| | | |_) | (_) | | | | |_| \\__ \\
\\_| \\_/\\___/ \\_/\\_/    \\__|_|   \\__, |  \\__,_| |_.__/ \\___/|_| |_|\\__,_|___/
                                 __/ |                                      
                                |___/                                       
               _                                  _                         
              (_)                                | |                        
  __ _ ___ ___ _  __ _ _ __  _ __ ___   ___ _ __ | |_                       
 / _` / __/ __| |/ _` | '_ \\| '_ ` _ \\ / _ \\ '_ \\| __|                      
| (_| \\__ \\__ \\ | (_| | | | | | | | | |  __/ | | | |_                       
 \\__,_|___/___/_|\\__, |_| |_|_| |_| |_|\\___|_| |_|\\__|                      
                  __/ |                                                     
                 |___/                                                      "
