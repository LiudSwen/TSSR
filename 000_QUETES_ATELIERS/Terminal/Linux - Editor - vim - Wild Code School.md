---
title: "Linux - Editor - vim - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/1545/pages/2959"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Terminal

## Linux - Editor - vim

Use vi(m) to edit files from the shell

Auto-validation

Terminal

## Linux - Editor - vim

## Introduction

To edit files, about every Linux or Unix operating systems provides at least the **vi** editor. **vi** stands for *visual editor*. As the shell will only allow character based input and output, it is not as visual as editors that you may have used in a graphical environment.

**vim** is a improved version of **vi** that replaces **vi** in modern Linux operating systems. Don't worry, **vi** and **vim** work the same for the basics commands introduced in this quest.

When you start **vim** the first impression is very *minimalistic*.

![vim screen](https://raw.githubusercontent.com/coseos/coseos-simple-png/main/2021/2021-02-17T19-45-37_Linux-Mint_Gnome-Terminal_vi-hello.txt.png)

The minimalism has historic reasons. **vi** was first released in 1976.

## 🤓 By the end of this quest, you will:

✅ Know what **vim** is  
✅ Know the basic commands to use **vim**

---

## 👉 Start editing files with vim

To start the **vi** editor from the shell, just type:

```bash
1
vim hello.txt
```

When you start **vim** you are in **command** mode. Typing characters will act as commands - be careful what you type. You may navigate within the file with the cursor keys, but since the file **hello.txt** did not exist before we started the editor, a new empty file is created and there is nothing to navigate through.

To add some content, type the `i` character to enter **insert** mode. You can now type some text in the file. To leave the **insert** mode, press the `Esc` key on your keyboard. You are now back in **command** mode. To save the file, type the colon character `:` followed by the `w` character to write the content to file *hello.txt*. To leave the editor, type the colon `:` followed by `q` character to quit the editor.

> In case you get lost, you can almost always leave the **vim** editor by pressing the **Esc** key followed by key sequence `:q!`

You can watch this video to learn some more basic commands and how to use **vim**.

## Lessons learned

Use of **vim** has it's pros and cons. A major pro is the fact that you can do everything with the basic keyboard. There is no need to use the mouse or special keys like the cursor keys. In case you are fast with the keyboard, **vim** is a very fast editor.

The major cons are the commands. You have to remember which character corresponds to a certain action. If you use a cheat sheet as a reference to the most important commands in **vim**, this will help you learn the basics of **vim** really fast.

Some cheat sheets that include the basic commands can be found on

- [vim cheat sheet](https://www.cs.cmu.edu/~15131/f17/topics/vim/vim-cheatsheet.pdf)
- [vi/vim cheat sheet](http://perugini.cps.udayton.edu/teaching/courses/Spring2017/cps499/LanguagePresentation/cheatsheet/samples/Vim_cheat_sheet.pdf)

You can use your search engine to search for a cheat sheet that suits your preferences of color or that provides a more details description.

---

## 🔬 Exercise

To get used with the basic commands in **vim** you have to practice. Just type in some text for that purpose. It can be anything. If you have no idea at all, describe some hobby or sport that you did or look for some news of the day. You should have at least 10 lines of about 60 characters in each line.

---

## 📝 Quiz

```bash
# 1  - How do you undo the last undo?Ctrl zCtrl rValider# 2  -  What does the D command do when used in command modeDeletes everything from cursor to end of fileDeletes a single characterValider# 3  -  What happens when you add an exclamation mark to the q commandYou exit vim without saving changesYou create a backup of the file you editValiderTon score :0 / 3
```

---

## ☝️ Summary

This quest introduced the **vim** editor. You now know the basics and can use **vim** to create text files.

---

## 💪 Challenge

The challenge for this quest is practice. Work with **vim** for at least one hour and learn at least 10 additonal commands. Write down a few notes about the commands you learned with **vim** and share these with other students.

Things to look for:

- Change from lower to uppercase or upper to lowercase
- Copy and paste of lines or blocks
- Search and replace with **vim**

## 🧐 Acceptance criteria

⭙ You used at least 10 **vim** commands on a file and feel reasonable comfortable  
⭙ You bookmarked a **vim** cheat sheet that you can use in the future

Don't worry, most people do not use **vim** for software development - it is basically a minimal common denominator available on all Linux operating systems.

Quête terminée le **samedi 25 octobre 2025**