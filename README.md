<div align="center">
  <br>
  <a href="https://jailbreak.party/discord"><img src="https://github.com/jailbreakdotparty/Erosion/blob/main/PreviewIcon.png?raw=true" alt="App Icon" width="150"></a>
  <br>
  <h1>Erosion</h1>
  <p>iOS customization toolbox using the <a href="https://github.com/forcequitOS/worse_query">worse_query</a> sandbox escape.</p>
  <p>Supports iOS 26.0 - 26.7.2 & iOS 27.0 - 27.2.1.</p>
  <a href="https://github.com/jailbreakdotparty/Erosion/releases/latest"><img alt="GitHub Downloads (all assets, all releases)" src="https://img.shields.io/github/downloads/jailbreakdotparty/Erosion/total?style=flat-square&color=CF7D46"></a>
  <a href="https://github.com/jailbreakdotparty/Erosion/stargazers"> <img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/jailbreakdotparty/erosion?style=flat-square&color=%23FFD300"></a> 
  <a href="https://jailbreak.party/discord"><img alt="Discord" src="https://img.shields.io/discord/1349128546072793218?style=flat-square&logo=discord&logoColor=FFFFFF&color=5865F2"></a> 
  <a href="https://jailbreak.party"><img alt="Static Badge" src="https://img.shields.io/badge/jailbreak.party-blue?style=flat-square&label=%20&color=3868DB"></a>
</div>

### Before you begin...
- Please create a backup of your device before usage! While Erosion has been extensively tested, there is still a possibility that you could lose your data by using this tool.
- If a tweak doesn't work how you were expecting, **do not open an issue or ask for support regarding it!** All tweaks are reliant on your device cooperating properly, and in some cases this can even involve Apple's servers. We'll be unable to help you.

### Supported Versions
>[!NOTE]
>If your version doesn't show up on this list, your device is not supported. **Do not ask us for any support regarding extending version support!** Exploits that apps like these rely on are very rare to come by, so there's nothing we can do if your device isn't supported.
- iOS/iPadOS 26.0 - 26.6.2 **(limited functionality, e.g. no gestalt tweaks)**
- iOS/iPadOS 27.0 - 27.2.1
- iOS/iPadOS 27.3 beta 1 (24C5037i)

At the time of writing (2026-11-08), worse_query has not been patched in any new software releases by Apple, so it works on all available versions.

Expect that to change in the short future.

### FAQ
1. **Why can't I use MobileGestalt tweaks on iOS 26?** The exploit that Erosion relies on, `worse_query`, is *not* capable of writing to MobileGestalt on iOS 26, therefore those tweaks do not work.
2. **Why aren't PosterBoard wallpapers showing up?** Sometimes, you'll have to reset Collections, which can be done in-app. If the wallpaper still doesn't show up after that, then it's likely a wallpaper-based issue rather than something that Erosion can solve.
3. **Where can I get dialer themes and custom wallpapers?** Check out https://cowabun.ga/wallpapers for these features.
4. **Why does the app hang when opening Custom Wallpapers or Dialer Themer?** When you open these tweaks for the first time, Erosion starts automatically detecting the app container paths. Unfortunately, the method currently used to detect these is annoyingly slow. It should complete in ~30 seconds, and this setup is only required once.

### Credits
- [lunginspector](https://github.com/lunginspector) - Primary developer and maintainer.
- [forcequit](https://github.com/forcequitOS) - worse_query sandbox escape and container enumeration strategy.
- [0xjohnny](https://github.com/0xjohnnydev) - worse_query sandbox escape.
- [Skadz](https://github.com/skadz108) - Exploit implementation, backend functions, and project maintainer.
- [rooootdev](https://github.com/rooootdev) - Various backend components.
- [neonmodder123](https://github.com/neonmodder123) - Developed WebView respring method.
