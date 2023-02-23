/* youtube-dl-qt is Free Software: You can use, study share
 * and improve it at your will. Specifically you can redistribute
 * and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version.
 * 
 * The original author of this code is : Robin de Rooij (https://github.com/rrooij)
 * The original repository of this code : https://github.com/rrooij/youtube-dl-qt 
 */

#ifndef MEDIAFORMAT_H
#define MEDIAFORMAT_H

#include <QString>

class MediaFormat
{
public:
    MediaFormat();
    QString getFormatId() const;
    void setFormatId(const QString &value);

    QString getExtension() const;
    void setExtension(const QString &value);

    QString getResolution() const;
    void setResolution(const QString &value);

    QString getQuality() const;
    void setQuality(const QString &value);

    QString getNote() const;
    void setNote(const QString &value);

    QString getFormat() const;
    void setFormat(const QString &value);

    QString getAcodec() const;
    void setAcodec(const QString &value);

    QString getVcodec() const;
    void setVcodec(const QString &value);

private:
    QString formatId;
    QString format;
    QString extension;
    QString resolution;
    QString quality;
    QString note;
    QString acodec;
    QString vcodec;
};

#endif // MEDIAFORMAT_H
